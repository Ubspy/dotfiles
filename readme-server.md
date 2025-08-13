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
- Then, you want to add your principle for NFS with `addprinc -randkey nfs/nfs-server`
- The naming scheme uses `service/username`, certain services can be configured using kerberos, like nfs, so they recognize when you add `nfs/` to the start of a principle.
- If there's no service, like for minecraft, or general file sharing, you can ommit a service 
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

# Reverse Proxy
- Install nginx: `apt intall curl nginx`.
- To setup the reverse proxy, you'll want to make a file in `/etc/nginx/sites-availible/` with the name of your service.
- I'll show you an example for `/etc/nginx/sites-availible/admin` for the proxmox admin portal:
```
server {
    listen 80;
    listen [::]:80;
    server_name admin.example.com # This is the domain that the reverse proxy will redirect from

    location / {
        proxy_pass http://<IP>:8006; # This IP you should set based on the IP of the web service we're proxying to
        include proxy_params;
    }
}
```
- To enable this, create a symlink in `/etc/nginx/sites-enabled/` with `ln -s /etc/nginx/sites-availible/admin /etc/nginx/sites-enabled/`.
- Test nginx configuration with `nginx -t`.
- Restart nginx with `systemctl reload nginx`

# NAS Server
- Install samba server: `apt install samba`
- I created a script to make new samba users:
```
#!/bin/bash

function usage {
	echo "./add-smb-user <user>"
}

if [ -z $1 ]; then
	usage
	exit
fi

GROUP=`getent group | grep sambashare | cut -d: -f3`

useradd -g $GROUP $1 -d /home/$1
mkdir /home/$1
usermod $1 -s /usr/sbin/nologin

chown $1:sambashare -R /home/$1

passwd $1
smbpasswd -a $1

systemctl enable --now krb-ticket@$1.service
systemctl enable --now krb-ticket@$1.timer
```
- Edit your configuration at `/etc/samba/smb.conf` and add the following at the end:
```
[NAS]
    comment = NAS Server
    path = /mnt
    browseable = yes
    read only = no
    guest ok = no
    valid users = @sambashare
    
    create mask = 0775      # Allows any user in sambashare to edit files made in NAS folder
    directory mask = 0775   # Allows any user in sambashare to edit files under directories made in NAS folder
```

# Arr Services
- First you want to follow the [Radarr Installation Guide](https://wiki.servarr.com/radarr/installation/linux).
- Do the same with any other of the -arr services, I personally use [Sonarr](https://sonarr.tv/#downloads-linux-ubuntu) also.
- To manage indexers, you should also set up [Prowlarr](https://wiki.servarr.com/prowlarr/installation/linux).
- As a downloader client, I'm using qbittorrent, but I am running it headless, so I need to start it without x server: `apt install qbittorrent-nox`
- For the first time run, run `qbittorrent-nox` in an ssh session, and accept the EULA, then login to the web UI at `http://IP:8080` and set the new password for login, the default username is `admin` and the default password is `adminadmin`
- To make it run after reboot: `systemctl enable qbittorrent-nox@qbtuser.service`

## My specific workflow
- For my workflow, I set the default download location at where I have my NFS mounted.
- I also need to give the `qbtuser` a kerberos ticket using `systemctl enable --now krb-ticket@qbtuser.service`
- I need to do the same for the -arr service users.
- I then need to edit the `/etc/systemd/system/multi-user.target.wants/qbittorrent-nox@qbtuser.service` file to add the `krb-ticket@qbtuser.service` to the `After=` section, and `ExecStartPre=/bin/sleep 10` to `[Services]` to make sure qbtuser has a valid ticket.
- I also need to install my VPN and set autoconnect, LAN-Discovery and disable the Firewall, see the `DNS Server > NordVPN` for more details here.
- I lastly in the qbittorrent advanced settings make sure the only adapter it uses is the `nordlynx` adapter to make sure it only uses VPN connections.

## FlareSolverr
- The easiest way to run this is docker, because the dependencies on this bad boy are wild, install docker: `apt install docker.io docker`
- Warning: this image takes >600Mbs, so make sure your VM has space for it.
- Then, you'll want to start the image with alwyas restart so it starts on boot: `docker run -d --name=laresolverr -p 8191:8191 -e LOG_LEVEL-inffo --restart always ghcr.io/flaresolverr/flaresolverr:latest`
- FlareSolverr is now running, and you can use it to bypass CloudFlare DNS protection.

## Prowlarr
- Login to prowlarr at `https://IP:9696` and add FlareSolverr as an indexer proxy in `Settings > Indexers > Indexer Proxies`.
- Add your indexers, I use public ones that allow sorting by seeders or relevancy.
- After that I select all and set a minimum seeder count to 50 seeders, this seems like a lot but public trackers almost always lie about seeder numbers.
- You then want to go to `Settings > Apps` and add whatever -arr services you are using.

## Radarr/Sonarr
- Add qbittorrent as the downloader
- Set max download size in `Settings > Indexers` to something you feel is appropriate, I did 20 GB since I will be using mostly 1080p.
- This should now work for you.

# JellyFinn
- Install JellyFin, follow instructions at [their official webpage](https://jellyfin.org/docs/general/installation/linux).
- You'll need to give access to the NFS storage: `systemctl enable --now krb-ticket@jellyfin.service` and `systemctl enable --now krb-ticket@jellyfin.timer`.
- You can then connect at `http://<IP>:8096`

## OpenSubtitles
- I like to install the OpenSubtitles plugin, this will automatically download subtitles.
- First you'll need to make an account on [their website](https://www.opensubtitles.com/).
- Then, download the zip file from the latest release on [this GitHub page](https://github.com/jellyfin/jellyfin-plugin-opensubtitles/releases/).
- Unzip the folder using `unzip` and move the DLL file to `/var/lib/jellyfin/plugins/opensubtitles` (you may need to create the `opensubtitles` directory first).
- After restarting JellyFin, add your login in the `Dashboard > Plugins` settings for OpenSubtitles.
- JellyFin should now start automatically downloading subtitles for your libraries, keep in mind this is limited to 20 a day.

## SSL
- If you're using a reverse proxy server like me, the following steps need to be completed on that VM instead of the one with Jellyfin installed.
- You need to install certbot and another python3 nginx package: `apt install certbot python3-certbot-nginx`.
- Edit your crontab using `crontab -e` and add the following job: `echo "0 0 * * 0 certbot renew --quiet --no-self-upgrade --post-hook 'systemctl reload nginx'`
- TODO: CHECK THIS
- TODO: MAYBE UNCOMMENT /etc/cron.d/certbot
- This cronjob will make sure your certificate bundle is automatically updated.

### Automatic Installation
- To try the automatic SSL certificatie installation, run `certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email YOUR_EMAIL -d DOMAIN_NAME`.
- Make sure you're using your public facing domain, because that's what it will be looking for.
- This didn't work for me, but it may for you! If it works, you can skip the manual section.
- Find the files that need to be specified in nginx, they should be in `/etc/ssl` somewhere.

### Manual Installation
- Download your SSL bundle from your domain broker, I'm using PorkBun and the certificates are through LetsEncrypt.
- Scp them onto the VM with nginx we're using as a reverse proxy.
- Copy the `domain.cert.pem` to `/etc/ssl/certs/domain_ext.domain.pem`
- Copy the `private.key.pem` to `/etc/ssl/private/domain_ext.private.key`
- Run `certbot certonly --manual --preferrred-challenges=dns --cert-path /etc/ssl/certs/domain_ext.domain.pen --key-path /etc/ssl/private/domain_ext.key.pem --chain-path /etc/ssl/certs/domain_ext.domain.pem`
- Specify the public facing domain that your bundle is for, and you should have it installed.
- For nginx, the `ssl_certificate` line should have your `/etc/ssl/certs/domain_ext.domain.pem` file specified after
- For nginx, the `ssl_certificate_key` line should have your `/etc/ssl/private/domain_ext.key.pem` file specified after

## Force the outside facing domain
- If you want to force SSL, you can, have a clause like this in your site config for Jellyfin:
```
server {
    listen 80;
    listen [::]:80;

    server_name local.only.comain.com;

    return 301 https://public_domain.com$requesturi;
}
```

# Nextcloud
- I want to set up Nextcloud in a particular way, I want the data to be shared between an smb server and nextcloud. Because of this, I do not use the AIO solution with Docker.
- I followed the manual setup, specifically the [Ubuntu example found here](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)
- Sometimes after installing the `mariadb-server` package and trying to accessit via `mysql`, it's broken. If you `apt purge mariadb-server` and then reinstall it, that usually fixes it for me.
- Once you get to the Apache configuration, make sure you enable the `rewrite, headers, env, dir, mime` modules.
- Edit the `.htaccess` file in `/var/www/nextcloud` and add this at the bottom: `php_value memory_limit 1G`.
- I think I just had this be erased after an update, make sure that doesn't happen when you update.

## Updating
- Speaking of, if you want to update Nextcloud, first ssh into the VM.
- Change to the `nextcloud` user using `su nextcloud -s /bin/bash`.
- Change directory into `/var/www/nextcloud`.
- As the nextcloud user, run this command: `php updater/updater.phar`
- Make sure afterwards to have it run `occ upgrade` and then disable maintenance mode.

## Making the data folder NFS mounted
- NFS mount another folder to use temporarily after the base install.
- Copy every file from `nextcloud/data` to this new location, sometimes cp misses hidden files, make sure those are copied too.
- This will likely need to be done as the `nextcloud` user, because of the KRB5 authentication `su nextcloud -s /bin/bash`.
- Move the current `nextcloud/data` folder somewhere else as a backup.
- Edit `/etc/fstab` to make sure the NFS is mounted at `/var/www/nextcloud/data`, reboot and this should work.

## Make it work with the Samba/NAS server
- I wanted Nextcloud to share data with my NAS server. It took a little tweaking, but I eventually got it to work.

### Edits to Samba server
- I want the samba server to have the same files as Nextcloud, the simplest fix if all your users are lowercase, is to have the path for the Samba login be `/mnt/%U/files` where `%U` is the unix username.
- This doesn't work for me, because my Nextcloud users are uppercase. What I did instead was created a directory `/srv/NAS/` where I have symlinks.
- For example, the Nextcloud dir is mounted at /mnt/ via NFS, and I have `/srv/NAS/ubspy` symlinked to `/mnt/Ubspy/files`. When `ubspy` logs in on the Samba server, they'll see their nextcloud files.
- Make sure linux users that have access to the samba server are in the same group. For example, if your webserver keeps the default `www-data` group, and the NFS server also has the files owned by `nogroup:www-data`, the Samba server users need the `www-data` group also.
- I recommend changing the default group, step in the next section.

### Edits to Nextcloud
- I changed the group that apache2 runs in, edit the `/etc/apache2/envvars`, and change the values of:
```
export APACHE_RUN_USER=www-data
export APACHE_RUN_GROUP=www-data
```
- I personally changed it to `nextcloud` and `nextcloud`, but it can be whatever you want.
- The `umask` for the user running Nextcloud needs to be altered. By default the umask is 0022, so when files are created with a 666 permission, it lowers it to 644.
- Unfortunately, this means when the users on the smb server try to write, it won't let them, since the files will only be owned by the group. We want a umask of 0002, so the group retains write permissions.
- To fix this, edit `/var/www/nextcloud/config/config.php` and add this line at in the config array:
```
'localstorage.umask' => 0002,
```
- By default, Nextcloud assumes the files are only edited by Nextcloud. Thankfully, there's a way to make it check for file updates.
- Open the crontab by using `crontab -e`, and add the following line at the bottom:
```
*/15 * * * * su apache-user -s /bin/bash -c "/usr/bin/php /var/www/nextcloud/occ files:scan --all"
```
- This will run the command every 15 minutes to scan for updated files, you can decrease this interval if you'd like, but it will increase server load.

### Nginx Config
- This is the config I have on the Nginx side, which is the reverse proxy that then points to the VM with Nextcloud and Apache2:
```
server {
	listen 80;
	listen [::]:80;
	
	server_name office.ubspy.org office.sudoserver.com;

	# Redirect to https
	return 301 https://office.ubspy.org$request_uri;
}

server {
	listen 443;
	listen [::]:443;

	server_name office.ubspy.org;

	# Use a variable to store the upstream proxy
	# in this example we are using a hostname which is resolved via DNS
	# (if you aren't using DNS remove the resolver line and change the variable to point to an IP address e.g `set $jellyfin 127.0.0.1`)
	set $nextcloud 192.168.1.87;

	# Set SSL certificate public and private key
	ssl_certificate /etc/ssl/certs/ubspy_org.domain.pem;
	ssl_certificate_key /etc/ssl/private/ubspy_org.private.key.pem;

	# Include ssl options and set params and trusted certificate
	include /etc/letsencrypt/options-ssl-nginx.conf;
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
	ssl_trusted_certificate /etc/ssl/certs/ubspy_org.domain.pem;

	# Prevent nginx HTTP Server Detection
	server_tokens off;

	# HSTS settings
	# WARNING: Only add the preload option once you read about
	# the consequences in https://hstspreload.org/. This option
	# will add the domain to a hardcoded list that is shipped
	# in all major browsers and getting removed from this list
	# could take several months.
	#add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

	# set max upload size and increase upload timeout:
	client_max_body_size 1G;
	client_body_timeout 600s;

	# Proxy and client response timeouts
	# Uncomment an increase these if facing timeout errors during large file uploads
	#proxy_connect_timeout 60s;
	#proxy_send_timeout 60s;
	#proxy_read_timeout 60s;
	#send_timeout 60s;

	# Enable gzip but do not remove ETag headers
	gzip on;
	gzip_vary on;
	gzip_comp_level 4;
	gzip_min_length 256;
	gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
	gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

	# Pagespeed is not supported by Nextcloud, so if your server is built
	# with the `ngx_pagespeed` module, uncomment this line to disable it.
	#pagespeed off;

	# The settings allows you to optimize the HTTP2 bandwidth.
	# See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
	# for tuning hints
	client_body_buffer_size 512k;

	location / {
		proxy_pass http://$nextcloud;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Forwarded-Protocol $scheme;
		proxy_set_header X-Forwarded-Host $http_host;

		# Disable buffering when nginx proxy gets resource heavy when streaming
		proxy_buffering off;
	}	
}
```
