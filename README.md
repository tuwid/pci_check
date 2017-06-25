# Security Baseline ( pci_check.pl )

## About this repository
This repository contains a perl script to check some basic security parameters (in case of quick audit reports) 

## Installation

	# git clone git@github.com:tuwid/pci_check.git
	# cd pci_check
And we run by doing

	# chmod +x pci_check.pl ; ./pci_check.pl

Or

	# perl pci_check.pl

## Basic usage
#### To use locally.
	./pci_check.pl
#### Remotely redirect to ssh.
	ssh username@servername perl < pci_check.pl
#### Looping through multiple servers.
	for server in servername1 servername2 servernameetc; do ssh username@$server perl < pci_check.pl; done
#### Redirect output to local file.
	ssh username@servername perl < pci_check.pl >> output.txt
#### Redirecting output to a local file while looping through multiple servers.
	for server in servername1 servername2 servernameetc; do ssh username@$server perl < pci_check.pl >> output.txt; done
#### Looping through multiple servers specified from a list.
	for server in `cat serverlist.txt` ; do ssh username@$server perl < pci_check.pl; done

## List of current checks

\### Todo: compile list of current checks


## Possible Todos

- add more relevant filters
- check environment variables for proxy ?
- check connectivity though proxy
- connectivity check though UDP DNS request (for udp tunneling attacks) 
- rsyslog check for remote forwarding
- ldap login check (centralized login auth)
- add email support for reports
- add suggestions (debsecan run + grep cve filter for HIGH )
- check if repo data ise updated
- list all crons from all users
- check if system has been updated in last 2 weeks
- add html output 
- find folders with 777 (?)
