echo "*****************************************************************************************************"
echo "****************************Cluster Inistialisation *************************************************"
echo "*****************************************************************************************************"
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo kubeadm init --apiserver-advertise-address=192.168.56.211 --pod-network-cidr 10.244.0.0/16
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo kubectl get nodes
sudo kubectl get pods -n kube-system