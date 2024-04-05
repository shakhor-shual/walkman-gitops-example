#!/usr/local/bin/cw4d
#################################################################################################
#   "BASHCL" play with TERRAFORM & ANSIBLE in old-fashion BASH-style
#################################################################################################
run@@@ = apply # possible here ( or|and in SHEBANG) are: validate, init, apply, destroy, new
debug@@@ = 2   # possible here are 0, 1, 2, 3

# ROOT
VM_name="@@this-host-01"
HOST="master-1"
DOMAIN="my.example.com"

credentials_file="~/.gcp/gcp.json"
project_id="foxy-test-415019"
region="europe-west1"
zone="$region-b"
vpc_name="new-@@this-vpc"
subnet_name="@@this-my-subnet"
subnet_cidr="192.168.0.0/24"

~VPC:
credentials_file=@@last # "@@last" annotation it just a "syntax-sugar"
project_id=@@last       # and ALL lines which contains IT can be removed
region=@@last           # from thе script without affecting his work
vpc_name=@@last         # they are present in the script only to illustrate
ssh_key_public=@@meta/@@this-public.key
ssh_key_private=@@meta/@@this=private.key

~FIREWALL:
credentials_file=@@last
project_id=@@last
namespace=@@this
region=@@last
network= <<<GET_from_state_by_type | google_compute_network | self_link
tag_allow_ssh="@@this-allow-ssh"
tag_allow_web="@@this-allow-web"

~MASTER_NODE:
credentials_file=@@last
project_id=@@last
region=@@last
zone=@@last
network_self_link= <<<GET_from_state_by_type | google_compute_network | self_link
subnetwork_self_link= <<<GET_from_state_by_type | google_compute_subnetwork | self_link
instance_name=$VM_name
host="master"
domain=$DOMAIN
machine_type="n2-standard-2"
image="debian-cloud/debian-10"
ssh_user="debi"
ssh_key_public=@@meta/@@this-public.key
ssh_key_private=@@meta/@@this-private.key
startup_script=@@meta/@@this-init.sh
tags="{master, $tag_allow_ssh }"
#ACCESS_ip=@@self/nat_ip
<<<SET_access_artefacts | nat_ip | $ssh_user | $ssh_key_private

~SLAVES_GROUP:
group_size=1
credentials_file=@@last
project_id=@@last
region=@@last
zone=@@last
network_self_link=@@last
subnetwork_self_link=@@last
instance_name=++last
host="worker"
domain=$DOMAIN
machine_type=@@last
image=@@last
ssh_user=@@last
ssh_key_public=@@last
ssh_key_private=@@last
startup_script=@@last
tags="{slaves, $tag_allow_ssh, $tag_allow_web }"
#ACCESS_ip=@@self/nat_ip
<<<SET_access_artefacts | nat_ip | $ssh_user | $ssh_key_private

~LOADED_GITOPS_STAGE
.

~SETUP_SLAVES
host=@@all
<<<SET_ansible_ready | $host | 20
playbooks="{init_slaves }"

~SETUP_MASTER:
host= ~MASTER_NODE_OF_CLUSTER
<<<SET_ansible_ready | $host | 20
playbooks="{init_master }"

#this initial dynamic-inventory settings for fifth SINGLE (for Ansible)
# Varibles for Ansible section