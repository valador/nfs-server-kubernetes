# nfs-server-kubernetes
!!! РАЗРЕШЕНИЕ КОРНЯ, подмонтировать в ручную и потестить

nable to attach or mount volumes: unmounted volumes=[nfs kube-api-access-gfzsb], unattached volumes=[nfs kube-api-access-gfzsb]: error processing PVC nfs/nfs-test: failed to fetch PVC from API server: persistentvolumeclaims "nfs-test" is forbidden: User "system:node:dev-srv" cannot get resource "persistentvolumeclaims" in API group "" in the namespace "nfs": no relationship found between node 'dev-srv' and this object 

apk update && apk add nfs-utils

mount -t nfs nfs-server.default.svc.cluster.local:/exports /mnt

mount -t nfs -o proto=tcp,port=2049 nfs-server.default.svc.cluster.local:/exports /mnt
mount -t nfs nfs-server.default.svc.cluster.local:/ /mnt
mount -t nfs dev-srv:/ /mnt/test
mount -v -t nfs -o vers=4,port=2049 nfs-server.default.svc.cluster.local:/ /mnt
mount -v -t nfs -o proto=tcp,port=2049 dev-srv:/ /mnt
sudo lsof -i -P -n | grep LISTEN

Приветствую, подскажите, есть шары NFS
/exports *(rw,sync,crossmnt,no_subtree_check,fsid=0)
/exports/media *(rw,sync,no_subtree_check,no_root_squash)
монтирую: mount -v -t nfs -o vers=4,port=2049 192.168.1.3:/media /mnt
Проблема - media должен монтироваться и сохранять права root (согласно опции no_root_squash) но этого не происходит, все файлы имеют права nobody как у корня шары(/exports) кто нибудь сталкивался с таким? Как решить?

# Для гитлаба (не помогло)
sudo chmod -R 777 /mnt/nfs-store/gitlab

sudo kubectl -n default get events --sort-by='{.lastTimestamp}'

https://github.com/ehough/docker-nfs-server
https://github.com/sjiveson/nfs-server-alpine

```BASH
    # чекать днс в кластере
    sudo kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup nfs-server.default
```

  mountOptions:
    - hard
    - timeo=600
    - retrans=3
    - proto=tcp
    - nfsvers=4.2
    - port=2050
    - rsize=4096
    - wsize=4096
    - noacl
    - nocto
    - noatime
    - nodiratime

NFS так и не работает как должен, либо контейнеры privileged: true либо SYS_ADMIN cap добавлять нужно.
Притом как серверу так и клиенту а это - не камильфо.
Весь косяк в том что у меня кубер крутится на убунте 20.04 которая в свою очередь крутится на virtualbox.
apparmor сходит с ума а может и ещё что. профиль для lxc частично правит проблему но не решает её в корне.
При загрузке пода с pv nfs - виснет наглухо не зависимо от опций.

### Обязательно требуется присвоить clusterIP так как при инициализации
### PV не пробивается внутренний днс, а только наружный

## NFS

1. для работы правила apparmor нужно поставить lxc

    ```BASH
    sudo apt-get install lxc --no-install-recommends
    sudo apt-get install -y nfs-common 
    ```

2. Далее загружаем правило

    ```BASH
    sudo apparmor_parser -r -W apparmor_profile
    # выгружаем если что
    sudo apparmor_parser -R apparmor_profile
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

4. Подымает nfs server, в Virtualbox можно подконнектится только если в поде указать SYS_ADMIN, иначе никак. 
    Как на голом железе с кубером - не тестировалось.

    ```BASH
    make nfs-std-up
    ```
с `privileged: true` работает только если выставить на сервере и на клиентах
сервер - `privileged: true` + apparmor профиль
клиент - `SYS_ADMIN` и apparmor профилем - монтирует - РАБОЧИЙ ВАРИАНТ
клиент - без капов но с apparmor профилем - `mount: permission denied (are you root?)`
клиент - капы DAC_READ_SEARCH, SYS_RESOURCE и apparmor профилем - `mount: permission denied (are you root?)`
сервер - с капами SYS_ADMIN и прочее + apparmor профиль
клиент - с капами SYS_ADMIN и профилем - `mount: mounting nfs-server.default.svc.cluster.local:/exports on /mnt failed: No such file or directory`