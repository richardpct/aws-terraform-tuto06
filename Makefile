.PHONY: apply destroy apply_base apply_bastion apply_database apply_webserver \
destroy_webserver destroy_database destroy_bastion destroy_base

apply: apply_base apply_bastion apply_database apply_webserver

destroy: destroy_webserver destroy_database destroy_bastion destroy_base

apply_base:
	cd 00-base; terraform apply -auto-approve

apply_bastion:
	cd 01-bastion; terraform apply -auto-approve

apply_database:
	cd 02-database; terraform apply -auto-approve

apply_webserver:
	cd 03-webserver; terraform apply -auto-approve

destroy_webserver:
	cd 03-webserver; terraform destroy -auto-approve

destroy_database:
	cd 02-database; terraform destroy -auto-approve

destroy_bastion:
	cd 01-bastion; terraform destroy -auto-approve

destroy_base:
	cd 00-base; terraform destroy -auto-approve
