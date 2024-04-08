#!/usr/local/bin/cw4d
###########################################################################
# Copyright The Vadym Yanik.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################
run@@@ = apply # possible here ( or|and in SHEBANG) are: validate, init, apply, destroy, new
debug@@@ = 2   # possible here are 0, 1, 2, 3
project@@@= plan9

# ROOT
VM_name="@@this-host-01"
HOST="master-1"
DOMAIN="my.example.com"

credentials_file="~/.gcp/gcp.json"
project_id="foxy-test-415019"
region="europe-southwest1"
zone="$region-a"
vpc_name="new-@@this-vpc"
subnet_name="@@this-my-subnet"
subnet_cidr="192.168.0.0/24"

~VPC:
credentials_file=@@last
project_id=@@last
region=@@last
vpc_name=@@last

~FIREWALL:
credentials_file=@@last
project_id=@@last
namespace=@@this
region=@@last
network= <<<GET_from_state_by_type | google_compute_network | self_link
tag_allow_ssh="@@this-allow-ssh"
tag_allow_web="@@this-allow-web"

~EXTRA_FIREWALL_FROM_GIT_STAGE_EXAMPLE
.
credentials_file=@@last
project_id=@@last
region=@@last
win_domain="@@this-domain"
network=@@last
ad_dc_tags= ["@@this_ad_master", "@@this_domain","domain_controllers"]
source_ranges=@@

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
machine_type="t2d-standard-1"
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
zone="$region-b"
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

~SETUP_SLAVES
host=@@all
<<<SET_ansible_ready | $host | 20
playbooks="{init_slaves }"

~SETUP_MASTER:
host= ~MASTER_NODE
<<<SET_ansible_ready | $host | 20
playbooks="{init_master }"
