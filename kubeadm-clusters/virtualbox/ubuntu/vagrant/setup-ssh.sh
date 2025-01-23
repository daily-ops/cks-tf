ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1

      node.vm.provision "shell", inline: "useradd -s /bin/bash -m ansible"
      node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/tmp/authorized_keys"
      node.vm.provision "shell", inline: "mkdir /home/ansible/.ssh && mv /tmp/authorized_keys /home/ansible/.ssh/ && chown ansible:ansible /home/ansible/.ssh/authorized_keys"
      node.vm.provision :shell do |s|