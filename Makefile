THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
.PHONY: load-modules
load-modules:
	sudo modprobe nfs
	sudo modprobe nfsd
# base nfs installation
.PHONY: nfs-std-up nfs-std-down nfs-purge test-up test-down
nfs-std-up: load-modules
	# # sudo mkdir -p /mnt/data_store/nfs
	# # sudo chown nobody:nogroup /mnt/data_store/nfs
	# sudo kubectl apply -f ./kuber_std_nfs/nfs-server-pv.yaml
	# # sudo kubectl apply -f ./kuber_std_nfs/nfs-server-pv-hostpath.yaml
	# sudo kubectl apply -f ./kuber_std_nfs/nfs-server-pvc.yaml
	# sudo kubectl apply -f ./kuber_std_nfs/nfs-server-service.yaml
	# # sudo kubectl apply -f ./kuber_std_nfs/nfs-server-rc.yaml
	# sudo kubectl apply -f ./kuber_std_nfs/nfs-server-custom.yaml
	sudo kubectl apply -f ./kuber_std_nfs/nfs-server-custom2.yaml
nfs-std-down:
	# sudo kubectl delete -f ./kuber_std_nfs/nfs-server-service.yaml
	# # sudo kubectl delete -f ./kuber_std_nfs/nfs-server-rc.yaml
	# sudo kubectl delete -f ./kuber_std_nfs/nfs-server-custom.yaml
	# sudo kubectl delete -f ./kuber_std_nfs/nfs-server-pvc.yaml
	# sudo kubectl delete -f ./kuber_std_nfs/nfs-server-pv.yaml
	# # sudo kubectl delete -f ./kuber_std_nfs/nfs-server-pv-hostpath.yaml
	sudo kubectl delete -f ./kuber_std_nfs/nfs-server-custom2.yaml
nfs-gan-up: load-modules
	sudo mkdir -p /mnt/nfs-store
	# sudo chown nobody:nogroup /mnt/data_store/nfs
	# sudo kubectl apply -f ./kuber_ganesha_nfs/psp.yaml
	sudo kubectl apply -f ./kuber_ganesha_nfs/nfs-server-conf.yml
	# sudo kubectl apply -f ./kuber_ganesha_nfs/nfs-server-pv.yaml
	# sudo kubectl apply -f ./kuber_ganesha_nfs/nfs-server-pvc.yaml
	sudo kubectl apply -f ./kuber_ganesha_nfs/nfs-server-service.yaml
	sudo kubectl apply -f ./kuber_ganesha_nfs/nfs-server-rc.yaml
nfs-gan-down:
	sudo kubectl delete -f ./kuber_ganesha_nfs/nfs-server-service.yaml
	sudo kubectl delete -f ./kuber_ganesha_nfs/nfs-server-rc.yaml
	# sudo kubectl delete -f ./kuber_ganesha_nfs/nfs-server-pvc.yaml
	# sudo kubectl delete -f ./kuber_ganesha_nfs/nfs-server-pv.yaml
	sudo kubectl delete -f ./kuber_ganesha_nfs/nfs-server-conf.yml
	# sudo kubectl delete -f ./kuber_ganesha_nfs/psp.yaml
nfs-purge:
	sudo rm -rf /mnt/nfs-store
test-up: load-modules
	# sudo kubectl apply -f ./test/nfs-pv.yaml
	# sudo kubectl apply -f ./test/nfs-pvc.yaml
	# sudo kubectl apply -f ./test/nfs-busybox-rc.yaml
	sudo kubectl apply -f ./nfs-test.yml
test-down:
	# sudo kubectl delete -f ./test/nfs-busybox-rc.yaml
	# sudo kubectl delete -f ./test/nfs-pvc.yaml
	# sudo kubectl delete -f ./test/nfs-pv.yaml
	sudo kubectl delete -f ./nfs-test.yml
.PHONY: build-ganesha-debian build-ganesha-fedora build-ganesha-izdock build-std-nfs
build-ganesha-debian:
	docker build \
		--file ./ganesha_debian/Dockerfile \
		--tag slayerus/ganesha:debian \
		./ganesha_debian/.
	docker push slayerus/ganesha:debian
build-ganesha-fedora:
	docker build \
		--file ./ganesha_fedora/Dockerfile \
		--tag slayerus/ganesha:fedora \
		./ganesha_fedora/.
	docker push slayerus/ganesha:fedora
build-ganesha-izdock:
	docker build \
		--file ./izdock-nfs-ganesha/Dockerfile \
		--tag slayerus/ganesha:izdock \
		./izdock-nfs-ganesha/.
	docker push slayerus/ganesha:izdock
build-std-nfs:
	docker build \
		--file ./nfs_std_server/Dockerfile \
		--tag slayerus/nfs-std:alpine \
		./nfs_std_server/.
	docker push slayerus/nfs-std:alpine