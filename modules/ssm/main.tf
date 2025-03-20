data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


resource "aws_ssm_parameter" "rapid7_token" {
  name  = var.ssm_param_name
  type  = "String"
  value = var.ssm_param_value
}


resource "aws_resourcegroups_group" "all_named_instances_rg" {
  name        = "${data.aws_caller_identity.current.account_id}_${data.aws_region.current.name}_ec2_rg"
  description = "All instances with a Name tag"
  tags = {
    owner = "dcops"
  }

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "Name"
    }
  ]
}
JSON
  }
}

resource "aws_ssm_maintenance_window" "trio-maintenance-Window" {
  name     = "Sophos-Rapid7-PatchManager-Jobs"
  schedule = "cron(0 1 0 ? * *)"
  duration = 3
  cutoff   = 1
  tags = {
    owner = "dcops"
  }
}

resource "aws_ssm_maintenance_window_target" "trio-target" {
  window_id     = aws_ssm_maintenance_window.trio-maintenance-Window.id
  name          = "trio-maintenance-window-target"
  description   = "trio-maintenance-window-target"
  resource_type = "RESOURCE_GROUP"

  targets {
    key    = "resource-groups:Name"
    values = [aws_resourcegroups_group.all_named_instances_rg.name]
  }
}


resource "aws_ssm_document" "trio_windows" {
  name            = var.ssm_doc_windows
  document_format = "YAML"
  document_type   = "Command"
  tags = {
    owner = "dcops"
  }

  content = <<DOC
schemaVersion: "2.2"
description: Install Sophos, Rapid7 and Patch manager Plus agent from S3 for Windows servers
parameters:
  token:
    type: String
    default: "{{ ssm:${aws_ssm_parameter.rapid7_token.name} }}"

  executionTimeout:
    type: String
    default: "3600"

mainSteps:
  - action: aws:runPowerShellScript
    name: CreateTempFolder
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - if(Test-Path -Path 'C:\dco-tmp-705924564' ) {Remove-item -path 'C:\dco-tmp-705924564' -force -recurse};
        - New-Item -ItemType Directory -Path C:\ -Name dco-tmp-705924564 -Force
  - action: aws:downloadContent
    name: downloadSophos
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      SourceType: S3
      SourceInfo:
        path: "${var.ssm_sophos_url_windows}"
      destinationPath: C:\dco-tmp-705924564
  - action: aws:downloadContent
    name: downloadRapid7
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      SourceType: S3
      SourceInfo:
        path: "${var.ssm_rapid7_url_windows}"
      destinationPath: C:\dco-tmp-705924564
  - action: aws:downloadContent
    name: downloadPmp
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      SourceType: S3
      SourceInfo:
        path: "${var.ssm_pmp_url_windows}"
      destinationPath: C:\dco-tmp-705924564
  - action: aws:runPowerShellScript
    name: InstallingSophos
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - cd 'C:\dco-tmp-705924564';
        - if([System.Environment]::Is64BitOperatingSystem) {$installPath = 'C:\Program Files (x86)\Sophos\Management Communications System\Endpoint\McsClient.exe'} else {$installPath = 'C:\Program Files\Sophos\Management Communications System\Endpoint\McsClient.exe'};
        - if(Test-Path $installPath) {Write-output "Sophos is already installed"} else {Start-Process -FilePath "SophosSetup.exe" -ArgumentList "--quiet" | Write-Verbose}
  - action: aws:runPowerShellScript
    name: InstallingRapid7Agent
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - cd 'C:\dco-tmp-705924564';
        - if(test-path -path 'C:\Program Files\Rapid7\Insight Agent\ir_agent.exe') {Write-output "Rapid7 agent is already installed"} else {msiexec.exe /i "agentInstaller-x86_64.msi" /l*v insight_agent_install_log.log CUSTOMTOKEN={{ token }} /quiet /qn | Write-Verbose};
  - action: aws:runPowerShellScript
    name: InstallingPatchManagerAgent
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - cd 'C:\dco-tmp-705924564';
        - if([System.Environment]::Is64BitOperatingSystem) {$regkey = 'HKLM:SOFTWARE\Wow6432Node\AdventNet\DesktopCentral\DCAgent'} else {$regkey = 'HKLM:SOFTWARE\AdventNet\DesktopCentral\DCAgent'};
        - if(Test-Path $regkey) {$agentVersion =(Get-ItemProperty $regkey).DCAgentVersion};
        - if( -not $agentVersion) {Expand-Archive -Path .\pmp.zip -DestinationPath .; msiexec /i "UEMSAgent.msi" /qn TRANSFORMS="UEMSAgent.mst" ENABLESILENT=yes REBOOT=ReallySuppress INSTALLSOURCE=Manual SERVER_ROOT_CRT="%cd%\DMRootCA-Server.crt" DS_ROOT_CRT="%cd%\DMRootCA.crt" /lv "Agentinstalllog.txt" | Write-Verbose} else {Write-Output "Patch Manager agent is already installed"}
  - action: aws:runPowerShellScript
    name: PostInstallationCleanup
    precondition:
      StringEquals:
      - platformType
      - Windows
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - Remove-item -path 'C:\dco-tmp-705924564' -force -recurse;
DOC
}

resource "aws_ssm_maintenance_window_task" "aws_ssm_windows_trio_task" {
  max_concurrency = "50%"
  max_errors      = "100%"
  priority        = 1
  task_arn        = aws_ssm_document.trio_windows.arn
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.trio-maintenance-Window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.trio-target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"

    }
  }

}


resource "aws_ssm_document" "duo_linux" {
  name            = var.ssm_doc_linux
  document_format = "YAML"
  document_type   = "Command"
  tags = {
    owner = "dcops"
  }

  content = <<DOC
schemaVersion: "2.2"
description: Install Sophos, Rapid7 from S3 for debian based servers
parameters:
  token:
    type: String
    default: "{{ ssm:${aws_ssm_parameter.rapid7_token.name} }}"

  executionTimeout:
    type: String
    default: "3600"

mainSteps:
  - action: aws:downloadContent
    name: downloadSophos
    precondition:
      StringEquals:
      - platformType
      - Linux
    inputs:
      SourceType: S3
      SourceInfo:
        path: ${var.ssm_sophos_url_linux}
      destinationPath: /tmp/dco-705924564/
  - action: aws:downloadContent
    name: downloadRapid7
    precondition:
      StringEquals:
      - platformType
      - Linux
    inputs:
      SourceType: S3
      SourceInfo:
        path: ${var.ssm_rapid7_url_linux_x64_deb}
      destinationPath: /tmp/dco-705924564/
 
  - action: aws:runShellScript
    name: InstallingPrograms
    precondition:
      StringEquals:
      - platformType
      - Linux
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - |
          #!/usr/bin/env bash

          wdir=/tmp/dco-705924564
         
          sudo su

          if [ -d "$wdir" ]
          then

              cd "$wdir"

          else

              echo "$wdir not found"
            exit 99

          fi


          # Get the distribution
          . /etc/os-release

          case $ID in
            ubuntu) osname="Debian" ; ext="deb"
            ;;
            debian) osname="Debian" ; ext="deb"
            ;;
            amzn) osname="Redhat" ; ext="rpm"
            ;;
            rhel) osname="Redhat" ext="rpm"
            ;;
            *) osname="Not found"
            ;;
          esac
         
          # Get the architecture
          architecture="$(uname -m)"

          if [ "$architecture" = x86_64 ];
          then

              archcode="amd64"

          elif [ "$architecture" = ARM64 ]
          then

              archcode="arm64"

          else

              echo "Unknown Platform"

          fi


          # Install Rapid7 if not installed

          if systemctl is-active --quiet ir_agent.service

          then

              echo "Rapid7 agent is installed and running"

          else
              # Extracting Rapid7 version from the file name
          
              if [ -f rapid7-insight-agent-*".$ext" ]
              then

                  r7=$(ls rapid7-insight-agent-*".$ext")
                  version=$(sed 's/^.*agent-// ; s/-.*//' <<< "$r7")
              fi
              
              # Installing the Rapid7 agent on Debian based OS

              if [ "$osname" = "Debian" ] && [ "$archcode" = amd64 ]
              then

                filename="rapid7-insight-agent-$${version}-1.$${archcode}.$${ext}"
                scriptLocation="/opt/rapid7/ir_agent/components/insight_agent/$${version}"
                echo "Installing rapid7 version $version, $archcode package on $architecture based system"
                rapid7="$${wdir}/$${filename}"
                apt-get install "$rapid7" -y && cd "$scriptLocation"
                ./configure_agent.sh --token {{ token }}

              else

                echo "Distribution or architecture not supported"

              fi
          fi

          # Install Sophos if not installed

          if sudo systemctl is-active --quiet sophos-spl.service
          then

              echo "Sophos is installed and running"

          else

            sophos_executable="$${wdir}/SophosSetup.sh"

            if [ -f "$sophos_executable" ]
            then

                cd "$wdir"
                sudo chmod +x SophosSetup.sh && sudo ./SophosSetup.sh --do-not-disable-auditd

            else

                echo "SophosSetup.sh not found"

            fi
          fi

          # Make sure all services are enabled and started
          systemctl enable --now ir_agent.service
          systemctl enable --now sophos-spl.service

  - action: aws:runShellScript
    name: PostInstallationCleanup
    precondition:
      StringEquals:
      - platformType
      - Linux
    inputs:
      timeoutSeconds: "{{ executionTimeout }}"
      runCommand:
        - rm -rf /tmp/dco-705924564
DOC
}

resource "aws_ssm_maintenance_window_task" "aws_ssm_linux_duo_task" {
  max_concurrency = "50%"
  max_errors      = "100%"
  priority        = 2
  task_arn        = aws_ssm_document.duo_linux.arn
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.trio-maintenance-Window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.trio-target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"

    }
  }

}
