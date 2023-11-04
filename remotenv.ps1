$option = $args[0]

$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE
$username = $env:USERNAME
$python_version =$(Invoke-Command {python --version})
$python_version = $python_version.SubString(7,$python_version.Length - 7).Split(".")
$python_version = $python_version[0] + $python_version[1]

if($option -ne "build" -And $option -ne "cmdlets"){
  Write-Host "
.\remotenv.ps1

  build: set up remote dev environment
  cmdlets: build powershell cmdlets
  "
}elseif($option -eq "build"){
  $project = $(Invoke-Command {Split-Path -Path (Get-Location) -Leaf}).ToString()
  cd "$($env:USERPROFILE)\AppData\Local\Programs\Python\Python$($python_version)"
  Invoke-Command {.\python.exe "$($location)/readyaml.py" $($location)}

  $setting = Read-Host "mode (docker, remote machine)"
  $Content = Get-Content "$($location)/config.txt"

  if($setting -ne "docker" -And $setting -ne "remote machine"){
    Write-Host "Invalid mode"
  }elseif($setting -eq "docker"){
    try{
      $environment = $Content[0].Split(":")[1]
      $framework = $Content[1].Split(":")[1]
      cd $location
      Invoke-Command {docker run --name $($project) -v .:/$($project) -itd ubuntu}
      $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt upgrade -y"}
      if($environment -eq "powershell"){
        Invoke-Command {docker exec -it $docker_name sh -c "apt install -y wget apt-transport-https software-properties-common"}
        Invoke-Command {docker exec -it $docker_name sh -c "apt install wget"}
        Invoke-Command {docker exec -it $docker_name sh -c "wget -q 'https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb'"}
        Invoke-Command {docker exec -it $docker_name sh -c "dpkg -i packages-microsoft-prod.deb"}
        Invoke-Command {docker exec -it $docker_name sh -c "rm packages-microsoft-prod.deb"}
        Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
        Invoke-Command {docker exec -it $docker_name sh -c "apt install -y powershell"}

      }
      Invoke-Command {docker exec -it $docker_name sh -c "apt install -y $($framework)"}
      Write-Host "$($docker_name)"
      Invoke-Command {docker exec -it $docker_name /bin/bash}
    }catch{
        Write-Host $_
    }
}else{
    try{
      $environment = $Content[0].Split(":")[1]
      $framework = $Content[1].Split(":")[1]
      $ip = $Command[2].Split(":")[1]

      Invoke-Command {docker run --name $($project) -v .:/$($project) -itd ubuntu}
      $docker_name = Invoke-Command {docker container ls --all --quiet --filter "name=$($project)"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt update"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt upgrade -y"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt install openssh-client -y"}
      Invoke-Command {docker exec -it $docker_name sh -c "ssh-keygen -t rsa"}
      Invoke-Command {docker exec -it $docker_name sh -c "apt install iputils-ping"}
      Invoke-Command {docker exec -it $docker_name sh -c "ping -c 1 -W 1 172.17.0.3; echo $? > status.log"}
    }catch{
      Write-Host $_
    }
  }
} 

cd "$($location)"