# nfs-server-kubernetes

Unable to attach or mount volumes: unmounted volumes=[nfs kube-api-access-gfzsb], unattached volumes=[nfs kube-api-access-gfzsb]: error processing PVC nfs/nfs-test: failed to fetch PVC from API server: persistentvolumeclaims "nfs-test" is forbidden: User "system:node:dev-srv" cannot get resource "persistentvolumeclaims" in API group "" in the namespace "nfs": no relationship found between node 'dev-srv' and this object 

mount -t nfs nfs-server.default.svc.cluster.local:/ /mnt

mount -t nfs -o proto=tcp,port=2049 nfs-server.default.svc.cluster.local:/ /mnt

mount -t nfs 10.43.32.157:/ /mnt

mount -v -t nfs -o vers=3,port=111 nfs-server.default.svc.cluster.local:/ /mnt

sudo lsof -i -P -n | grep LISTEN

sudo kubectl -n default get events --sort-by='{.lastTimestamp}'

## NFS

1. для работы правила apparmor нужно поставить lxc

    ```BASH
    apt-get install lxc --no-install-recommends
    ```

2. Далее загружаем правило

    ```BASH
    sudo apparmor_parser -r -W apparmor_profile
    # выгружаем если что
    apparmor_parser -R apparmor_profile
    ```

    ```MD
    container.apparmor.security.beta.kubernetes.io/<container_name>: <profile_ref>

    Where <container_name> is the name of the container to apply the profile to, and <profile_ref> specifies the profile to apply. The profile_ref can be one of:

        runtime/default to apply the runtime's default profile
        localhost/<profile_name> to apply the profile loaded on the host with the name <profile_name>
        unconfined to indicate that no profiles will be loaded
    ```

3. В UBUNTU по умолчанию ставится nfs-common и подымает rpcbind сервис, сервис нужно отключить
    иначе порт 111 будет занят.

    ```BASH
    sudo systemctl stop rpcbind.service
    sudo systemctl mask rpcbind
    sudo systemctl stop rpcbind.socket
    sudo systemctl disable rpcbind.socket
    ```
