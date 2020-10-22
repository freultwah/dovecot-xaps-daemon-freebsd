# iOS push e-mail daemon for Dovecot, FreeBSD port

This one's meant to be a pretty FreeBSD port for the [dovecot-xaps-daemon](https://github.com/freswa/dovecot-xaps-daemon). Just install, copy etc/xapsd/xapsd.yaml.sample to etc/xapsd/xapsd.yaml, provide your Apple ID and the hashed password, enable it in /etc/rc.conf or wherever you enable daemons (enable_xapsd="YES"), and you're good to go. The daemon fetches the relevant certificate and key all by itself.
