THIS_FILE := $(lastword $(MAKEFILE_LIST))

SHELL := /bin/bash

.PHONY: help
help:
	make -pRrq -f $(THIS_FILE) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# base nfs installation
.PHONY: nfs-up nfs-down nfs-purge
nfs-up:
	sudo mkdir -p /mnt/data_store/nfs
	sudo kubectl apply -f ./nfs-server-pv.yaml
	sudo kubectl apply -f ./nfs-server-pvc.yaml
	sudo kubectl apply -f ./nfs-server-rc.yaml
	sudo kubectl apply -f ./nfs-server-service.yaml
nfs-down:
	sudo kubectl delete -f ./nfs-server-pv.yaml
	sudo kubectl delete -f ./nfs-server-pvc.yaml
	sudo kubectl delete -f ./nfs-server-rc.yaml
	sudo kubectl delete -f ./nfs-server-service.yaml
nfs-purge:
	sudo rm -rf /mnt/data_store/nfs
