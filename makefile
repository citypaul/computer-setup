.PHONY: all deps personal work dock setup keys sudo_prompt cli gui

define sudo_prompt
	@if [ -z "$(SUDO_PASSWORD)" ]; then \
		read -s -p "Enter your sudo password: " SUDO_PASSWORD; \
		echo; \
		if ! echo "$$SUDO_PASSWORD" | sudo -S echo "Sudo access granted" >/dev/null 2>&1; then \
			echo "Sudo access denied. Please try again."; \
			exit 1; \
		fi; \
		export SUDO_PASSWORD; \
	fi
endef

all: setup deps personal

work: setup deps work

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

personal: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags install,personal

work: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags install,work

keys: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook personal-keys.yaml --ask-vault-pass

cli: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags cli

gui: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags gui

dock:
	@ansible-playbook local.yaml --tags dock

setup: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook setup.yaml

sudo_prompt:
	$(call sudo_prompt)