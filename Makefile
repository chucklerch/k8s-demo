.DEFAULT_GOAL := help
MAKEFLAGS += --silent

BLUE=\033[36m
NC=\033[0m

KUBECTL_OPTS:=--dry-run=client --output=yaml

.PHONY: install-kustomize
install-kustomize: # Install kustomize
	@echo "${BLUE}Installing kustomize.${NC}"
	gh release download --repo kubernetes-sigs/kustomize --pattern '*linux_amd64.tar.gz' --output kustomize.tgz
	tar xvf kustomize.tgz -C ~/bin/ kustomize
	rm kustomize.tgz

.PHONY: install-yq
install-yq: # Install yq
	@echo "${BLUE}Installing yq.${NC}"
	gh release download --repo mikefarah/yq --pattern '*_linux_amd64.tar.gz' --output yq.tgz
	tar xvf yq.tgz -O ./yq_linux_amd64  > ~/bin/yq
	chmod +x ~/bin/yq
	rm yq.tgz

.PHONY: base
base: # Start base version of webapp
	@echo "${BLUE}Starting base website.${NC}"
	kustomize build base --output output/

.PHONY: testing
testing: # Start testing version of webapp
	@echo "${BLUE}Starting testing website.${NC}"
	kustomize build overlays/testing --output output/

.PHONY: istio
istio: # Enable Istio
	@echo "${BLUE}Starting Istio enalbled website.${NC}"

.PHONY: external
external: # Make application Internet accessible
	@echo "${BLUE}Starting external website.${NC}"

.PHONY: clean
clean: # Delete everything
	@echo "${BLUE}Cleaning.${NC}"
	rm -rf output/*
	kubectl delete deployment,ing,cm,secret,netpol,pdb,svc,all -l app=webapp

.PHONY: port-forward
port-forward: # Port forward to webapp
	@echo "${BLUE}Port forwarding.${NC}"
	kubectl port-forward service/webapp 8080:http

.PHONY: help
help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
