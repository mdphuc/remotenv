# remotenv v1.0

#
This project is designed to help developers deploy and test their code on a remote environment of their choice, whether is docker, virtual machine, remote machine, or cloud machine. One of the problem I think this project is gonna come in handy is the difference between dev environment and the environment that they want to build their code for. Utilizing this project, developers can choose to use Windows as their development environment and run code on linux, or vice versa. It will be an isolated environment, offering user an option of reset everything to the starting point when finish with their program, not having to worry about extra library or module, framework, or environment, that are not really important for their code.

- This project is created in MakeUC Hackathon 2023
- Teammate: Lan Duong, Tin Le, Minh Hoang

## Table of Content
1) [Installation](#installation)
2) [Usage](#usage)
3) [Requirement](#requirement)
4) [Yaml Guide](#yaml)
5) [Contributing Policy](#contributing)
6) [Constraints](#constraints)
7) [License](#license)

## Installation
run ```pip install -r requirements.txt```
Use <a href="https://git-scm.com/" target="_blank">git</a> to install:
```bash
git clone https://github.com/mdphuc/remotenv.git
```
run `./setup.ps1` as administrator to set up the program as powershell cmdlets

## Usage
```powershell
remotenv
  build:            set up remote dev environment
                        docker: build docker container
                        remote machine: use remote machine as remote dev environment
  cmdlets:          build powershell cmdlets
```
- For ```remote machine``` function
  - Copy ssh public key located in ```<your project name>/.ssh/id_rsa.pub```
  - Create a file called authorized_keys in ```~/.ssh/```, which contain the public key that you copy previously
  - Run `remotenv ssh` to set up first ssh connection
  - For more information, please visit this <a href="https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix">link</a>

## Yaml
Write your yaml file follow this order: `environment`, `framework`, `ip`, `username` and save the file as `Envfile.yml` in your project directory
#### Example 
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
- For more information, please visit this <a href="https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started">link</a>

## Requirement
- Python 3.5+
- Powershell 6+
- Windows 10+

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## Constraints
- This project depends heavily on the connection between docker container and docker container or remote machine. So for the best use, make sure they are configured so that they can be accessed from each other on the Internet

## License
[MIT](https://choosealicense.com/licenses/mit/)
