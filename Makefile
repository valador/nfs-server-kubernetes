THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY: load-modules
load-modules:
	# sudo modprobe {nfs,nfsd}
# base nfs installation
.PHONY: nfs-up nfs-down nfs-purge test-up test-down
nfs-up: load-modules
	# sudo mkdir -p /mnt/data_store/nfs
	# sudo chown nobody:nogroup /mnt/data_store/nfs
	sudo kubectl apply -f ./nfs-server-pv.yaml
	# sudo kubectl apply -f ./nfs-server-pv-hostpath.yaml
	sudo kubectl apply -f ./nfs-server-pvc.yaml
	sudo kubectl apply -f ./nfs-server-service.yaml
	# sudo kubectl apply -f ./nfs-server-rc.yaml
	sudo kubectl apply -f ./nfs-server-custom.yaml
nfs-down:
	sudo kubectl delete -f ./nfs-server-service.yaml
	# sudo kubectl delete -f ./nfs-server-rc.yaml
	sudo kubectl delete -f ./nfs-server-custom.yaml
	sudo kubectl delete -f ./nfs-server-pvc.yaml
	sudo kubectl delete -f ./nfs-server-pv.yaml
	# sudo kubectl delete -f ./nfs-server-pv-hostpath.yaml
nfs-purge:
	sudo rm -rf /mnt/data_store/nfs
test-up: load-modules
	sudo kubectl apply -f ./test/nfs-pv.yaml
	sudo kubectl apply -f ./test/nfs-pvc.yaml
	sudo kubectl apply -f ./test/nfs-busybox-rc.yaml
test-down:
	sudo kubectl delete -f ./test/nfs-busybox-rc.yaml
	sudo kubectl delete -f ./test/nfs-pvc.yaml
	sudo kubectl delete -f ./test/nfs-pv.yaml
.PHONY: build-ganesha
build-ganesha:
	docker build \
		--file ./ganesha_debian/Dockerfile \
		--tag slayerus/ganesha:latest \
		./ganesha_debian/.
	docker push slayerus/ganesha:latest