while true; do scp -i /root/.ssh/id_rsa -r /remotenv phuc@192.168.0.1:/remotenv 2>&1 </dev/null; sleep 30; done
