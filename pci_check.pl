#!/usr/bin/perl
#  Version 0.0.1.G alpha
#
#  To use locally.
#	example: 	"./pci_check.pl"
#
#  Remotely redirect to ssh.
#	example: 	"ssh username@servername perl < pci_check.pl"
#
#  Looping through multiple servers.
#	example: 	"for server in servername1 servername2 servernameetc; do ssh username@$server perl < pci_check.pl; done"
#
#  Redirect output to local file.
#	example: 	"ssh username@servername perl < pci_check.pl >> output.txt"
#
#  Redirecting output to a local file while looping through multiple servers.
#	example:	"for server in servername1 servername2 servernameetc; do ssh username@$server perl < pci_check.pl >> output.txt; done"
#
#  Looping through multiple servers specified from a list.
#	example:	"for server in `cat serverlist.txt` ; do ssh username@$server perl < pci_check.pl; done"
#

use strict;
my $internet_connectivity_url = "http://www.google.com";

my $which_cmd = "which";
my $etc_passwd_file = "/etc/passwd";
my $etc_login_defs_file = "/etc/login.defs";
my $etc_lsb_release_file = "/etc/lsb-release";
my $etc_redhat_release_file = "/etc/redhat-release";
my $etc_gentoo_release_file = "/etc/gentoo-release";
my $etc_ntp_conf_file = "/etc/ntp.conf";
my $etc_exports_file = "/etc/exports";
my $etc_fstab_file = "/etc/fstab";
my $etc_ssh_sshd_conf_file = "/etc/ssh/sshd_config";
my $var_log_clamav_freshclam_log = "/var/log/clamav/freshclam.log";
my $my_id = `id -u`;
my $sysctl_cmd = "/sbin/sysctl";
my $passwd_cmd = `$which_cmd passwd`;
  chomp $passwd_cmd;
my $curl_cmd = `$which_cmd curl`;
  chomp $curl_cmd;
my $crontab_cmd = `$which_cmd crontab`;
  chomp $crontab_cmd;
my $ifconfig_cmd= `$which_cmd ifconfig`;
  chomp $ifconfig_cmd;



my $hostname = `/bin/hostname`;
my @ps_cmd = `/bin/ps -eo %c h`;
my @ifconfig = `$ifconfig_cmd`;
my @netstat = `/bin/netstat -nlp`;
my @pam_d_contents = `/bin/cat /etc/pam.d/*  2> /dev/null`;
if ($my_id == 0)
  {
    my @crontab = `$crontab_cmd -l`;
  }


my @installed_packages;
my $os_distro;
my $ipv6_status;

my @sysctl_oids =
  qw(
    net.ipv4.conf.all.forwarding
    net.ipv4.conf.default.forwarding
    net.ipv4.ip_forward
    net.ipv4.conf.default.accept_source_route
    net.ipv4.conf.all.accept_source_route
  );

my @cron_directories =
  qw(
    /etc/cron.hourly
    /etc/cron.daily
    /etc/cron.weekly
    /etc/cron.montly
    );

my @log_directories =
  qw(
    /var/log
    /var/log/httpd
    );

my @login_defs = open_file($etc_login_defs_file);
my @etc_lsb_release = open_file($etc_lsb_release_file);
my @etc_redhat_release = open_file($etc_redhat_release_file);
my @etc_gentoo_release = open_file($etc_gentoo_release_file);
my @etc_ntp_conf = open_file($etc_ntp_conf_file);
my @etc_exports = open_file($etc_exports_file);
my @etc_fstab = open_file($etc_fstab_file);
my @etc_ssh_sshd_conf = open_file($etc_ssh_sshd_conf_file);
my @etc_passwd = open_file($etc_passwd_file);
my @clamav_freshclam = open_file($var_log_clamav_freshclam_log);


print "Hostname:\n\t$hostname";

#print whether internet connectivity is detected or not
if ( length($curl_cmd) != 0 )
  {
    if ( `$curl_cmd --silent -m 5 $internet_connectivity_url` )
      {
        print "\tINTERNET CONNECTIVITY DETECTED\n";
      }
    else
      {
        print "\tNO INTERNET CONNECTIVITY\n";
      }
  }

print "OS Version:\n";
foreach (@etc_lsb_release)
  {
    if (/DISTRIB_DESCRIPTION="(.*)"/)
      {
        print "\t$1\n";
	$os_distro = $1;
      }
  }

foreach (@etc_redhat_release)
  {
    if (/(.*)/)
      {
        print "\t$1\n";
        $os_distro = $1;
      }
  }
foreach (@etc_gentoo_release)
  {
    if (/(.*)/)
      {
         print "\t$1\n";
         $os_distro = $1;
      }
  }


#Loop through ifconfig for IP Addresses
print "IP Addresses:\n";
foreach (@ifconfig)
  {
    if (/inet (?:addr:)?([\d.]+)/)
      {
        print "\t$1\n";
      }
  }



#Loop through ifconfig for IPv6
foreach (@ifconfig)
  {
    if (/inet6/)
      {
        $ipv6_status = 1;
        last;
      }
  }

if ($ipv6_status)
  {
    print "IPv6 is Enabled\n";
  }
else
  {
    print "IPv6 is Disabled\n";
  }


#services
print "Listening Services:\n";
foreach (@netstat)
  {
    if (/(tcp|udp).* ([\d.\d.\d.\d]+:\d+)/)
      {
        print "\t$1 $2\n";
      }
  }



#Sysctl Values
print "IP sysctl:\n";
foreach (@sysctl_oids)
  {
    print "\t" . read_sysctl($_);
  }

#Enumerate System Users
print "Users:\n";
foreach (@etc_passwd)
  {
    my($login, $passwd, $uid, $gid,$gcos, $home, $shell) = split(/:/);
    print "\t$login\t$home\t$shell";
      if ( $my_id == 0 )
        {
          print "\t".`$passwd_cmd -S $login`;
        }
  }


#NTP server configuration
print "NTP Servers:\n";
foreach (@etc_ntp_conf)
  {
    if (m/^(server.*)/)
      {
        print "\t$1\n";
      }
  }

#List filesystem exports
print "Filesystem NFS Exports:\n";
foreach (@etc_exports)
  {
    if (!(m/^#/))
      {
	print "\t$_";
      }
  }


#etc fstab contents
print "fstab mounts:\n";
foreach (@etc_fstab)
  {
    if (!(m/^#/))
      {
        print "\t$_";
      }
  }

#etc sshd config contents
if ($my_id == 0)
  {
  print "sshd_conf:\n";
  foreach (@etc_ssh_sshd_conf)
    {
      if (!(m/^#/) && !(m/^$/))
        {
          print "\t$_";
        }
    }
  }


#Determine OS and find installed packages
if ($os_distro =~ m/ubuntu/i)
  {
    my @installed_packages_tmp = `/usr/bin/dpkg -l`;
    foreach (@installed_packages_tmp)
      {
        my @line =  split(/\s+/, $_);
        push @installed_packages, "$line[1]\t$line[2]\n";
      }
  }

if ($os_distro =~ m/debian/i)
  {
    my @installed_packages_tmp = `/usr/bin/dpkg -l`;
    foreach (@installed_packages_tmp)
      {
        my @line =  split(/\s+/, $_);
        push @installed_packages, "$line[1]\t$line[2]\n";
      }
  }

if ($os_distro =~ m/gentoo/i)
  {
    @installed_packages = `ls -d /var/db/pkg/*/*`;
  }

if ($os_distro =~ m/centos/i)
  {
    @installed_packages = `rpm -qa --last`;
  }

if ($os_distro =~ m/red hat/i)
  {
    @installed_packages = `rpm -qa --last`;
  }


print "Installed packages:\n";
foreach (@installed_packages)
  {
    if (m/(.*(ssh|ntp|httpd|apache|named|bind|avg|clam|portmap|sophos|sys|ssl|cups|sec|tripwire|php).*)/i)
    {
       print "\t$1\n";
    }
  }


if (-e $var_log_clamav_freshclam_log)
    {
      print "ClamAV Updates:\n";
      foreach (@clamav_freshclam[-30,-1])
        {
          print "\t$_";
        }
    }

print "File contents: login.defs\n";
foreach (@login_defs)
  {
    if (m/(^(MD5_CRYPT_ENAB|ENCRYPT_METHOD|LOGIN_RETRIES|LOGIN_TIMEOUT|LOG_OK_LOGINS|SYSLOG_SU_ENAB|PASS_MAX_DAYS).*)/i){print "\t$1\n";}
  }


print "Pam.d config:\n";
foreach (@pam_d_contents)
  {
    if ((!(m/^#/) && ((m/(.*pam_unix.*)/i) || (m/(.*pam_tally.*)/i) || (m/(.*pam_crack.*)/i) || (m/(.*minlen.*)/i) || (m/(.*retry.*)/i)) ) )
      {
        print "\t$1\n";
      }
  }

print "Cron Jobs:\n";
foreach my $file (@cron_directories)
  {
    foreach (<$file/*>)
      {
        print "\t $_\n";
      }
  }

print "Log Files:\n";
foreach my $file (@log_directories)
  {
    foreach (<$file/*>)
      {
	if (!(m/\.[0-9]/))
          {
            print "\t $_\n";
          }
      }
  }


#Sort unique processes
print "System Processes:\n";
my %seen;
foreach ( sort( grep{ ! $seen{$_}++ } @ps_cmd))
  {
    print "\t$_";
  }




#Argument filename, Returns array
sub open_file
  {
    my $file_name = $_[0];
    open FILE, "<$file_name"  || die "Can't open $file_name: $!\n";
    my @file_contents;
    while (<FILE>)
      {
        push(@file_contents, $_);
      }
    close FILE;
    return @file_contents;
  }

#Read specific sysctl
sub read_sysctl
  {
    my $search_oid=$_[0];
    open SYSCTL, "$sysctl_cmd $search_oid |" || die "Can't run sysctl: $!\n";
    my $output;
    while (<SYSCTL>)
      {
        $output = $_;
      }
    close SYSCTL;
    return $output;
  }