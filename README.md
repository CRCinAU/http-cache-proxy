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

Change the configuration options in the top of `index.pl`:
```
## Configuration goes here:
my $mirror_base = "http://mirror.aarnet.edu.au/pub/fedora/";	## Base URL to map to
my $local_base = "https://your.web.server/fedora/";		## Where the URL on your server syncs up
my $cache_path = "/var/www/html/fedora/";			## Where to save the actual files. The web server will need write access to this directory.
my $logfile = "/var/log/httpd/mirror_log";			## Where to log mirror details
```

Add the following to your apache configuration:
```
	ScriptAlias /fedora/ "/var/www/html/fedora/"
	<Directory /var/www/html/fedora>
		AddHandler cgi-script .pl
		RewriteEngine On
		RewriteBase /fedora/
		RewriteRule ^index\.pl$ - [L]
		RewriteRule . /fedora/index.pl [L]
	</Directory>
```
