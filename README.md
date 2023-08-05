This project is to act as an interactive proxy to download and cache software packages from
various mirrors. This allows a transparent cache to be used with something like dnf or apt
to download updated files once and consume them on multiple systems in a transparent manner.

The benefit is that each remote URL will only be downloaded once.

Currently, it does not work with `dnf`'s zchunk mode - so you'll need to disable zchunk by adding
`zchunk=false` to `/etc/dnf/dnf.conf`.

## Installation
Copy `index.pl` to `/var/www/html/fedora`.

Create a cache directory, and make sure that the web server can write to it:
```
mkdir -p /var/www/html/fedora/linux
touch /var/log/httpd/mirror_log
chown apache:apache /var/www/html/fedora/linux /var/log/httpd/mirror_log
```

Add the following to your apache configuration and change the SetEnv lines to suit your environment.
```
	ScriptAlias /fedora "/var/www/html/fedora/index.pl"
	<Directory /var/www/html/fedora>
		SetEnv	mirror_base	"http://mirror.aarnet.edu.au/pub/fedora/"
		SetEnv	local_base	"http://your.server.name/fedora/"
		SetEnv	cache_path	"/var/www/html/fedora/"
		SetEnv	logfile		"/var/log/httpd/mirror_log"

		AddHandler cgi-script .pl
	</Directory>
```
