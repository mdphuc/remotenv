Function remotenv{  
  $option = $args[0]

  $location = $(Invoke-Command {Get-Location}).ToString()
  $drive = $($location)[0..1] -join ''
  $user = $env:USERPROFILE
  $username = $env:USERNAME
  $python_version =$(Invoke-Command {python --version})
  $python_version = $python_version.SubString(7,$python_version.Length - 7).Split(".")
  $python_version = $python_version[0] + $python_version[1]

  if($option -ne "build" -And $option -ne "cmdlets" -And $option -ne "ssh"){
    Write-Host "
  remotenv
    build:            set up remote dev environment
                          docker: build docker container
                          remote machine: use remote machine as remote dev environment
    cmdlets:          build powershell cmdlets
    "
  }elseif($option -eq "build"){
    $project = $(Invoke-Command {Split-Path -Path (Get-Location) -Leaf}).ToString()
    cd "$($env:USERPROFILE)\AppData\Local\Programs\Python\Python$($python_version)"
    Invoke-Command {.\python.exe "$($drive)/Windows/System32/WindowsPowerShell/v1.0/Modules/remotenv/readyaml.py" "$($location)"}

    $setting = Read-Host "Mode (docker, remote machine)"
    $Content = Get-Content "$($location)/config.txt"
    Invoke-Command {rm "$($location)/config.txt"}

    if($setting -ne "docker" -And $setting -ne "remote machine" -And $setting -ne "ssh"){
      Write-Host "Invalid mode"
    }elseif($setting -eq "docker"){
      $mode = Read-Host "Mode (build, reset)"
      if($mode -ne "build" -And $mode -ne "reset"){
        Write-Host "Invalid Option"
      }elseif($mode -eq "build"){
        try{
          $environment = $Content[0].Split(":")[1]
          $framework = $Content[1].Split(":")[1]
          cd $location
          Invoke-Command {docker run --name $($project) -v .:/$($project) --workdir /$($project) -itd ubuntu}
          $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt upgrade -y"}
          if($environment -eq "powershell"){
            Invoke-Command {docker exec -it $docker_name sh -c "apt install -y wget apt-transport-https software-properties-common"}
            Invoke-Command {docker exec -it $docker_name sh -c "wget -q 'https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb'"}
            Invoke-Command {docker exec -it $docker_name sh -c "dpkg -i packages-microsoft-prod.deb"}
            Invoke-Command {docker exec -it $docker_name sh -c "rm packages-microsoft-prod.deb"}
            Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
            Invoke-Command {docker exec -it $docker_name sh -c "apt install -y powershell"}

          }
          if($framework -eq "python" -Or $framework -eq "python3" -Or $framework -eq "python2"){
            Invoke-Command {docker exec -it $docker_name sh -c "apt install -y python3"}
          }else{
            Invoke-Command {docker exec -it $docker_name sh -c "apt install -y $($framework)"}
          }
          Write-Host "$($docker_name)"
          Invoke-Command {docker exec -it $docker_name /bin/bash}
        }catch{
            Write-Host $_
        }
      }elseif($mode -eq "reset"){
        $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
        Invoke-Command {docker stop $($docker_name)}
        Invoke-Command {docker system prune -f}
      }
    }else{
      $mode = Read-Host "Mode (build, reset)"
      if($mode -ne "build" -And $mode -ne "reset"){
        Write-Host "Invalid mode"
      }elseif($mode -eq "build"){
        try{
          $environment = $Content[0].Split(":")[1]
          $framework = $Content[1].Split(":")[1]
          $ip = $Content[2].Split(":")[1]
          $username = $Content[3].Split(":")[1]
          cd $location
          Invoke-Command {docker run --name $($project) --network host -v .:/$($project) -itd ubuntu}
          $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt upgrade -y"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt install openssh-client -y"}
          Invoke-Command {docker exec -it $docker_name sh -c "apt install systemctl -y"}
          Invoke-Command {docker exec -it $docker_name sh -c "ssh-keygen -t rsa"}
          Invoke-Command {docker exec -it $docker_name sh -c "mkdir /$($project)/.ssh"}
          Invoke-Command {docker exec -it $docker_name sh -c "cp ~/.ssh/id_rsa.pub /$($project)/.ssh"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo '#!/bin/bash' >> /$($project)/monitor.sh"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo 'while true; do scp -i ~/.ssh/id_rsa -r /$($project) $($username)@$($ip):/ 2>&1 </dev/null; sleep 1; done' >> /$($project)/monitor.sh"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo 'Host dev' >> /$($project)/config"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo '  HostName $($ip)' >> /$($project)/config"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo '  User $($username)' >> /$($project)/config"}
          Invoke-Command {docker exec -it $docker_name sh -c "echo '  IdentityFile ~/.ssh/id_rsa' >> /$($project)/config"}
          Invoke-Command {docker exec -it $docker_name sh -c "mv /$($project)/config ~/.ssh"}
          Invoke-Command {cp "$($drive)/Windows/System32/WindowsPowerShell/v1.0/Modules/remotenv/bash/monitor.service" $location}
          Invoke-Command {docker exec -it $docker_name sh -c "cp /$($project)/monitor.service /lib/systemd/system/monitor.service"}
          Invoke-Command {docker exec -it $docker_name sh -c "cp /$($project)/monitor.sh /usr/bin/monitor.sh"}
          Invoke-Command {docker exec -it $docker_name sh -c "systemctl daemon-reload"}
          Invoke-Command {docker exec -it $docker_name sh -c "systemctl enable monitor.service"}
          Invoke-Command {docker exec -it $docker_name sh -c "systemctl start monitor.service"}
          Invoke-Command {rm "$($location)/monitor.service"}
          Invoke-Command {rm "$($location)/monitor.sh"}
        }catch{
          Write-Host $_
        }
      }elseif($mode -eq "reset"){
        $ip = $Content[2].Split(":")[1]
        $username = $Content[3].Split(":")[1]
        $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
        Invoke-Command {docker exec -it $docker_name sh -c "cd /"}
        Invoke-Command {docker exec -it $docker_name sh -c "ssh -i /root/.ssh/id_rsa $($username)@$($ip) 'rm -rf /$($project)'"}
        Invoke-Command {docker stop $($docker_name)}
        Invoke-Command {docker system prune -f}
      }
    }
  }elseif($option -eq "cmdlets"){
    Invoke-Command {powershell -f ./module.ps1}
  }elseif($option -eq "ssh"){
    cd "$($location)"
    $project = $(Invoke-Command {Split-Path -Path (Get-Location) -Leaf}).ToString()
    cd "$($env:USERPROFILE)\AppData\Local\Programs\Python\Python$($python_version)"
    Invoke-Command {.\python.exe "$($drive)/Windows/System32/WindowsPowerShell/v1.0/Modules/remotenv/readyaml.py" "$($location)"}

    cd "$($location)"
    $Content = Get-Content "$($location)/config.txt"
    Invoke-Command {rm "$($location)/config.txt"}

    $ip = $Content[2].Split(":")[1]
    $username = $Content[3].Split(":")[1]
    $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
    Invoke-Command {docker exec -it $docker_name sh -c "ssh -i ~/.ssh/id_rsa $($username)@$($ip)"}
  }

  cd "$($location)"
}

Export-ModuleMember -Function "remotenv"