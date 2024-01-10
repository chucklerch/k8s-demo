.DEFAULT_GOAL := help
MAKEFLAGS += --silent

BLUE=\033[36m
NC=\033[0m

.PHONY: init
init: # Initialize the project
	@echo "${BLUE}Initializing.${NC}"
	mkdir -p output

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
	kubectl apply -f output/

.PHONY: ha
ha: # Start HA version of webapp
	@echo "${BLUE}Starting HA website.${NC}"
	kustomize build overlays/ha --output output/
	kubectl apply -f output/

.PHONY: ingress
ingress: # Start ingress / HA version of webapp
	@echo "${BLUE}Starting ingress website.${NC}"
	kustomize build overlays/ingress --output output/
	kubectl apply -f output/

.PHONY: v1
v1: # Start version 1.0.0 of webapp
	@echo "${BLUE}Starting v1 website.${NC}"
	kustomize build overlays/v1 --output output/
	kubectl apply -f output/

.PHONY: v2
v2: # Start version 2.0.0 of webapp
	@echo "${BLUE}Starting v2 website.${NC}"
	kustomize build overlays/v2 --output output/
	kubectl apply -f output/

# Get 1 pod name to be used in debug target
POD != kubectl get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}' 2> /dev/null
.PHONY: debug
debug: # Starting debug container
	@echo "${BLUE}Starting debug container.${NC}"
	kubectl debug --quiet -it --image-pull-policy=Always --image=busybox --target=nginx $(POD)

.PHONY: testing
testing: # Start testing version of webapp
	@echo "${BLUE}Starting testing website.${NC}"
	kustomize build overlays/testing --output output/

.PHONY: istio
istio: # Enable Istio
	@echo "${BLUE}Starting Istio enalbled website.${NC}"

.PHONY: clean
clean: # Delete everything
	@echo "${BLUE}Cleaning.${NC}"
	kubectl delete -f output/
	rm -rf output/*

.PHONY: port-forward
port-forward: # Port forward to webapp
	@echo "${BLUE}Port forwarding.${NC}"
	kubectl port-forward service/webapp 8080:http

.PHONY: help
help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
