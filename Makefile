.DEFAULT_GOAL := help
MAKEFLAGS += --silent

BLUE=\033[36m
NC=\033[0m

KUBECTL_OPTS:=--dry-run=client --output=yaml --namespace=chuck

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

.PHONY: base default
base default: # Start base version of webapp
	@echo "${BLUE}Starting base website.${NC}"
	kustomize build base | yq

.PHONY: istio
istio: # Enable Istio
	@echo "${BLUE}Starting Istio enalbled website.${NC}"

.PHONY: external
external: # Make application Internet accessible
	@echo "${BLUE}Starting external website.${NC}"

.PHONY: clean
clean: # Delete everything
	@echo "${BLUE}Cleaning.${NC}"
	kubectl delete deployment,ing,cm,cert,secret,netpol,so,pdb,all -l app=webapp
	kubectl delete vs,pa,destinationrules,envoyfilters -l app=webapp

.PHONY: help
help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
