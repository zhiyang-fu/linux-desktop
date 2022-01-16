# linux-desktop
linux desktop installation and configuration

## WiFi Connection using iwctl (iwd)
see [here](https://www.reddit.com/r/archlinux/comments/nlpr7l/wifi_connection_with_iwctl_university_network)

/var/lib/iwd/ssid-name.8021x looks like

[Security] 
EAP-Method=PEAP
EAP-Identity=anonymous
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=username
EAP-PEAP-Phase2-Password=password

[Settings]
AutoConnect=true
