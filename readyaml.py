import yaml 
import sys

sys.argv.remove(sys.argv[0])
location = sys.argv[0]



with open(f"{location}/Envfile.yml","r") as f:
    config = yaml.safe_load(f)


with open(f"{location}/config.txt", "w") as f:
  f.write(f"environment:{config['environment']}\n")
  f.write(f"framework:{config['framework']}\n")
  f.write(f"ip:{config['ip']}\n")
  f.write(f"username:{config['username']}\n")


