SHELL=/bin/bash

#check if HOST var is set
define HOSTS_ERROR_MSG
HOSTS variable is not set.
endef

check-host-var:
    ifndef HOSTS
	$(error $(HOSTS_ERROR_MSG))
    endif


install-requirements:
	ansible-galaxy install --force -r requirements.yml

bootstrap-server: check-host-var
	ansible-playbook ./playbooks/initial_bootstrap.yaml -l '$(HOSTS)' &&\
			ansible-playbook ./playbooks/default_packages.yaml -l '$(HOSTS)'

start-airflow: check-host-var
	ansible-playbook ./playbooks/start_airflow_server.yaml -l '$(HOSTS)'

start-metrics: check-host-var
	ansible-playbook ./playbooks/start_metrics.yaml -l '$(HOSTS)'

start-monitor: check-host-var
	ansible-playbook ./playbooks/start_monitor_server.yaml -l '$(HOSTS)'

start-rev-proxy: check-host-var
	ansible-playbook ./playbooks/start_reverse_proxy.yaml -l '$(HOSTS)'
	

help:
	@echo "Usage: make <target> HOSTS=<host-pattern>"
	@echo ""
	@echo "example:  make bootstrap-server HOSTS=airflow-server-0,monitor-server-0"
	@echo ""
	@echo "Available targets:"
	@echo "  install-requirements    Install Ansible Galaxy roles specified in requirements.yml."
	@echo "  bootstrap-server        Run initial server setup and install default packages."
	@echo "  start-airflow           Start the Airflow server on the specified hosts."
	@echo "  start-metrics           Start the metrics monitoring services."
	@echo "  start-monitor           Start the monitoring server on the specified hosts."
	@echo "  start-rev-proxy         Start the reverse proxy server."
	@echo "  help                    Display this help message."