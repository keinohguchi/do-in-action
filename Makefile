WAIT_SECONDS ?= 30

# for recursive call
export WAIT_SECONDS

all: deploy

# Some terraform command aliases.
.PHONY: init plan show output apply
init plan show output apply: tags
	terraform $@

.PHONY: deploy
deploy: init plan
	terraform apply -auto-approve
	$(MAKE) -C flips $@

.PHONY: tags
tags:
	$(MAKE) -C $@ deploy

.PHONY: test
test: deploy wait
	ansible-playbook tests/all.yml

.PHONY: test-all
test-all: clean test test-firewalls

.PHONY: test-firewalls
test-firewalls: test
	$(MAKE) -C firewalls test

.PHONY: wait
wait:
	sleep $(WAIT_SECONDS)

.PHONY: clean clean-all
clean: init
	$(MAKE) -C flips $@
	terraform destroy -force
	$(MAKE) -C tags $@
	$(RM) *.tfstate*
	$(RM) tests/*.retry
	$(RM) *.log
clean-all: init
	$(MAKE) -C firewalls clean-all
	$(MAKE) clean
