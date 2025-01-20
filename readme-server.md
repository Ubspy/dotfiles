# Proxmox server
Unrelated to my Arch setup, I wanted to document steps for myself on things I might want to remember for my Proxmox home server setup.
- HP server needs 2 ethernet connections. The one on board is for HP iLO, and the other one is for the actual device ethernet
- Proxmox enterprise sources need to be commented out in /etc/apt/sources.list.d/*
- Fans are a bit much, currently they're idling around 30%, I am seeing that the HD controller is at 80C without the server being closed. However, closing the server (putting the lid on) lowered it to 56C
- DNS server doesn't play with NordVPN without meshnet, install nordvpn on the DNS server, and on both the host and the DNS server, run `nordvpn set meshnet enabled`, and check the meshnet IP of the DNS server. On your machine, run `nordvpn set dns [DNS-mesh-ip]`

# DNS Server
- Install Adguard Home, instructions at [their GitHub page](https://github.com/AdguardTeam/AdGuardHome#getting-started)
- Assuming you know the VM's IP (you should), go to your browser and connect to `https://IP:3000` 
- Set up your DHCP settings, I just copied mine from what my router was using, this way your network devices use your DNS server
- Add `HaGeZi's Pro Blocklist` to DNS block lists
- Add DNS rewrites for local DNS resolution to appropriate VMs
- Here is my DNS upstream list, set it to whatever you want:
```
https://dns.mullvad.net/dns-query
https://dns.nextdns.io
9.9.9.10
1.1.1.1
```

## Nord VPN
- I use NordVPN, and I want to be able to have this DNS block list when I'm at home, so it's ideal to setup meshnet to be able to use this DNS server as a NordVPN mesh device.
- First, install nordvpn, you'll have to follow the directions on their site, if I link it here, it probably will just redirect to a login page.
- Next, since you're on a VM without any kind of GUI interface or web browser, you're going to want to get an access token on NordVPN's portal. I set mine to not expire, which isn't as secure, but oh well.
- Once nordvpn is installed, login by using `nordvpn login --token <generated-token>`
- You'll then want to adjust your settings:
```bash
nordvpn set meshnet enabled # Meshnet is what allows nordvpn to see this IP as a valid dns server
nordvpn set autoconnect enabled # Make sure we're always connected
nordvpn set lan-discovery enabled # Lets this device be seen by LAN devices
nordvpn set firewall disabled # If I didn't disable the firewall then no devices could talk to the DHCP server
```

Check the IP of the meshnet by using `ip addr`. On your client that uses NordVPN, set the NordVPN DNS server to this meshnet IP, either through the GUI, or `nordvpn set dns <ip>`.

### Use device as a VPN
- My work blocks NordVPN, and I still want to be able to use it. We need to edit the meshnet peer settings to allow your mobile device to use the DNS server as a VPN. Use `nordvpn meshnet peers list` to see your peers.
- Find the IP if your mobile device, and give it reroute permissions using `nordvpn meshnet peer routing allow <ip>`.

# Kerberos Server
## Installation
- First, you need to install the kerberos server packages from apt: `apt install krb5-user krb5-admin-server krb5-kdc`.
- During the installation it will ask you for the the default realm, you want to enter your domain name, for the purposes of this we'll use `EXAMPLE.COM`
- Next we have to configure our KDC, edit the `/etc/krb5.conf` file, it should look like this:
```
[libdefaults]
    default_realm = EXAMPLE.COM

[realms]
    EXAMPLE.COM {
        kdc = localhost
        admin_server = localhost
    }

[domain_realm]
    example.com = EXAMPLE.COM
    .example.com = EXAMPLE.COM
```
- For some strange reason, the krb5 packages don't actually add `EXAMPLE.COM` as a realm when you install, so you'll want to add it as a realm by running `krb5_newrealm EXAMPLE.COM`
- You'll then want to configure your admin, edit the `/etc/krb5kdc/kadm5.acl` file, and add the following:
```
*/admin@EXAMPLE.COM *
```

## Adding users
### Creating them on the KDC
- I'm using kerberos to have users authenticate with NFS, so I'm going to show you how to set up your first user for that.
- First, you want to enter the admin environment by using `kadmin.local`
- Then, you want to add your principle for NFS with `addkey -randkey nfs/nfs-server`
- The naming scheme uses `service/username`, certain services can be configured using kerberos, like nfs, so they regocnize when you add `nfs/` to the start of a principle.
- Add the user using `addkey -randkey user`
- Now you'll want to add these to a key file, unless you want to type the password every 12 hours when the key expires
- Use `ktadd -kt /etc/krb5.keytab nfs/nfs-server` to add the nfs principle to the keytab
- Do the same with the user: `ktadd -kt /etc/krb5.keytab user`

### Configuring the clients
- The NFS server will need in its keytab file every user who is going to authenticate with it, while the user only needs the user, and the NFS server. I keep mine all in the same keytab file, just to make things easier.
- You'll then want to put this keytab in the `/etc/krb5.keytab` file in both the client authenticating with NFS, and the NFS server.
- On the client, you'll need the nfs common tools, the server tools for ID mapping, and the krb5 user tools: `apt install krb5-user nfs-common nfs-server`
- On the NFS server, you'll want to mark all of your exports in `/etc/exports` with the option `sec=krb5`
- On the client and server, edit the `/etc/idmapd.conf` file, and make sure that the domain is `example.com`, the same as your kerberos realm server.
- On the client, make sure the keytab file is readable by whatever user and group will need access to it, I'm going to pretend that I'm setting this up for a user called `nfs-user` on the client to get access. So `/etc/krb5.keytab` will be need to be owned by `X:nfs-user`, assuming `nfs-user` is that user's GID.
- On the client, set up the mount in fstab or by using the `mount` command as you normally would for NFS, but make sure the type is `nfs4`, not `nfs`.
- You'll want to make sure that `nfs-server.example.com` points to the IP address of your NFS server. `nfs-server` because of the username in the principle, and `example.com` is the realm of the kerberos server.
- If you don't have any DNS setup, you can edits your `/etc/hosts` file on the client to add `IP    nfs-server  nfs-server`.
- On the client, ensure that the user `user` exists, or the user with the same name as your kerberos principle, we will not be using this user, but it's required for idmap and kerberos to properly authenticate.
- Finally, you'll want to grab a ticket using kinit, and specifying it's from the keytab file: `kinit -k user`.
- You should be able to access the mounted NFS directory now.
- One last point of note, ensure that on the NFS server, that the directory to be mounted and the files within are owned by the user `user`, or the username of the kerberos principle that will be used to access them. The username of the linux user accessing them does not matter, but the NFS server should have a user named after that kerberos principle, and the folder and files should be owned by them.
- If all is setup correct, you should be able to access and write to the mounted directory now.

### Automatically obtaining a ticket
- If you have something like a samba server, you won't be logging in to run `kinit -k user` every 12 hours when the kerberos ticket expires.
- I wrote a service with a timer that automatically does this for you, here are the contents of the service:
```
# File Name: krb-ticket@.service
# Location: /etc/systemd/system

[Unit]
Description=Obtain a Kerberos ticket for the given user %I
After=network.target

[Service]
ExecStart=/usr/bin/kinit -k user
User=%I
Group=<GID that has access to /etc/krb5.keytab>
Type=oneshot

[Install]
WantedBy=multi-user.target
```
- Then, you'll also want a timer to refresh this ticket after it expires:
```
# File Name: krb-ticket@.timer
# Location: /etc/systemd/system

[Unit]
Description=Refresh Kerberos ticket for user %I after expiration

[Timer]
OnBootSec=1min
OnUnitActiveSec=10h # Check your ticket expiration time on the KDC server at /etc/krb5kdc/kdc.conf, make sure this one is less by just a little
Unit=krb-ticket%I.service

[Install]
WantedBy=timers.target
```
- Then, to set it so a user automatically always has a ticket: `systemctl enable --now krb-ticket@user.service`.
- Also enable the timer: `systemctl enable --now krb-ticket@user.service`.
- It may be better to just change the ticket life on the KDC to infinite, but this seems more secure and it took me so long to get this working I didn't want to touch it once it finally worked.
