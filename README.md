# remotenv v1.0

This project is designed to help developers deploy and test their code on a remote environment of their choice, whether is docker, virtual machine, remote machine, or cloud machine. One of the problem I think this project is gonna come in handy is the difference between dev environment and the environemnt that they want to build their code for. Utilizing this project, developers can choose to use Windows as their development environment and run code on linux, or vice versa. It will be an isolated environment, offering user an option of reset everything to the starting point when finish with their program, not having to worry about extra library or module, framework, or environment, that are not really important for their code.

## Installation
Use <a href="https://git-scm.com/" target="_blank">git</a> to install:
```bash
git clone https://github.com/mdphuc/remotenv.git
```

## Usage
run ```pip install -r requirements.txt```
```powershell
.\remotenv.ps1

  build:            set up remote dev environment
                        docker: build docker container
                        remote machine: use remote machine as remote dev environment
  cmdlets:          build powershell cmdlets
```
- For cmdlets function: run ./remotenv.ps1 cmdlets as administrator
- Then when run the program again, just simply run ```remotenv```
- For ```remote machine``` function
  - Copy ssh public key located in ```<your project name>/.ssh/id_rsa.pub```
  - Create a file called authorized_keys in ```~/.ssh/```, which contain the public key that you copy previously
  - For more information, please visit <a href="https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix">this link</a>

## YAML Guide
Write your yaml file follow this order: `environment`, `framework`, `ip`, `username` and save the file as `Envfile.yml` in your project directory
##### Example 
```
environment:
  powershell (or bash)

framework:
  python (or nodejs or other framework)

ip:
  192.168.0.1

username:
  phuc
```

## Requirement
- Python 3.5+
- Powershell 6+
- Windows 10+

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## Constraints
- This project depends heavily on the connection between docker container and docker container or remote machine. So for the best use, make sure they are configured so that they can be accessed from each other on the Internet
