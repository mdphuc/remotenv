# $Content = Get-Content config.txt
# Write-Host $Content

Invoke-Command {docker exec -it c898a564726f sh -c "ping -c 1 -W 1 172.17.0.3; echo $?"}
