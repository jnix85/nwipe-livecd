# Minimal Disk Image
#
sshpw --username=root --plaintext WIZ@rfd0oz
# Firewall configuration
firewall --enabled
# Use network installation
url --url=http://mirror.centos.org/centos/7/os/x86_64
repo --name=updates --baseurl=http://mirror.centos.org/centos/7/updatesx86_64
repo --name=extras --baseurl=http://mirror.centos.org/centos/7/extras/x86_64
repo --name=epel --baseurl=http://download.fedoraproject.org/pub/epel/7/x86_64

# Root password
rootpw --plaintext WIZ@rdf0oz
# Network information
network  --bootproto=dhcp --onboot=on --activate
# System authorization information
auth --useshadow --enablemd5
# System keyboard
keyboard --xlayouts=us --vckeymap=us
# System language
lang en_US.UTF-8
# SELinux configuration
selinux --enforcing
# Installation logging level
logging --level=info
# Shutdown after installation
shutdown
# System timezone
timezone  US/Eastern
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part / --fstype="ext4" --size=4000
part swap --size=1000

%post --log=/mnt/sysimage/root/ks-post.log
# Remove root password
passwd -d root > /dev/null

# Remove random-seed
rm /var/lib/systemd/random-seed

### This sets up automatic login for the root user. In 100% of cases this is bad.
### Since this LiveCD is to nuke disks, we'll allow it this time

## remove original tty1
rm /mnt/sysimage/etc/systemd/system/getty.target.wants/getty@tty1.service

## write new tty1
cat > /mnt/sysimage/etc/systemd/system/getty@tty1.service << EOF
# Automatic login for root
[Unit]
Before=getty.target
Description=Getty on %I
Documentation=man:agetty(8) man:systemd-getty-generator(8)
Documentation=http://0pointer.de/blog/projects/serial-console.html
After=systemd-user-sessions.service plymouth-quit-wait.service
After=rc-local.service

IgnoreOnIsolate=yes
ConditionPathExists=/dev/tty0

[Service]
ExecStart=-/sbin/agetty --autologin root --noclear %I
Type=idle
Restart=always
RestartSec=0
UtmpIdentifier=%I
TTYPath=/dev/%I
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
KillMode=process
IgnoreSIGPIPE=no
SendSIGHUP=yes

Environment=LANG= LANGUAGE= LC_CTYPE= LC_NUMERIC= LC_TIME= LC_COLLATE= LC_MONETARY= L    C_MESSAGES= LC_PAPER= LC_NAME= LC_ADDRESS= LC_TELEPHONE= LC_MEASUREMENT= LC_IDENTIFIC    ATION=

[Install]
Alias=getty@tty1.service
WantedBy=getty.target
DefaultInstance=tty1
EOF

### Link the new unit file
ln -s /mnt/sysimage/etc/systemd/system/getty@tty1.service /mnt/sysimage/etc/systemd/system/getty.target.wants/getty@tty1.service

### Make nwipe start when root logs in
echo 'nwipe' >> /mnt/sysimage/root/.bash_profile

%end

%packages
@core
kernel
memtest86+
grub2-efi
grub2
shim
syslinux
-dracut-config-rescue
epel-release
nwipe

%end
