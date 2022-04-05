# Satellite Demo env installer

This is a simple demo environment provisioner for Satellite to install based on Ansible and Terraform.
It creates:

- libvirt-network with DHCP/DNS
- libvirt-pool for your VMS
- Satellite server
- RHEL7 and RHEL8 Client for demo purposes

## Host setup

### Download Terraform

VM setup is based on Terraform, it instantiates three virtual machine, *satellite*, *el7-server* and *el8-server*, kickstarting the setup.

First you need to download and install Terraform:

    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform

### Install Ansible

You need to follow the instructions in [Ansible Website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package) to proceed and install Ansible on your machine.

## Lab provisioning

The provisioner consists of two playbooks, that configure the underlying components (VM, network) and prepares the guests to install Satellite.

The first playbook is **provision-lab.yml** which takes care of creating KVM resources. It only has a single variable: 

| Variable | Value |
|--|--|
| **network_cidr** | Defaults to 192.168.211.0/24 |

The package comes with an inventory:

    localhost ansible_connection=local
    [satellite]
    satellite.satellitedemo.labs ansible_user=sysadmin

The playbook can either download RHEL 7.9 and RHEL 8.5 images, or work with pre-downloaded images. The only requirement is that the images need to be placed in the playbook directory with the name **rhel7.iso** and **rhel8.iso**

To download the images via the playbook, you will be prompted to enter your [Offline Token](https://access.redhat.com/management/api) to download resources.

**IMPORTANT** If you don't want to download images (it's around 20GB), just leave the variable blank.

Once you set the *network_cidr* variable to the desired value, you can run the playbook:

    ansible-playbook -i inventory provision-lab.yml

It takes around 20-25 minutes to be up and running. If you experience last step of the playbook being hanging after the machines are completely installed, **relaunch** the playbook as sometimes the ping module gets stuck.

## Satellite setup

With your lab up and running, you can proceed installing Satellite using the provided **satellite-setup.yml** playbook.

    ansible-playbook -i inventory setup-satellite.yml

It will ask for:

- RHNID (Username)
- Password
- PoolID of the subscription

It will install Satellite with:  

| Variable | Value |
|--|--|
| Organization | Red Hat |
| Location | Raleigh  |
| Username | admin |
| Password | redhat |

## Test your configuration

If the setup was good, you will be able to access your IdM server on [https://satellite.satellitedemo.labs](https://satellite.satellitedemo.labs)