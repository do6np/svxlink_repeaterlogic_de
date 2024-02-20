#!/bin/bash
################################################################################
# Installations-Skript für SvxLink_RepeaterLogic_De
################################################################################
echo
echo "SvxLink_RepeaterLogic_De - Installer"
echo
echo "*** BETA-VERSION, NUTZUNG AUF EIGENE GEFAHR! ***"
echo
echo "`date +%T`: Kopiere Konfiguration..."
DIRFOUND=0
if [ -d /etc/svxlink/svxlink.d ]; then
	DIRFOUND=1
	sudo cp repeater.conf /etc/svxlink/svxlink.d
fi
if [ -d /usr/local/etc/svxlink/svxlink.d ]; then
	DIRFOUND=1
	sudo cp repeater.conf /usr/local/etc/svxlink/svxlink.d
fi
if [ $DIRFOUND == 0 ]; then
	echo "`date +%T`: SvxLink-Installation nicht gefunden!"
	exit 1
fi
echo "`date +%T`: Kopiere Ablaufsteuerung..."
sudo mkdir -p /usr/share/svxlink/events.d/local
sudo cp *.tcl /usr/share/svxlink/events.d/local
sudo chown -R svxlink:svxlink /usr/share/svxlink/events.d
echo "`date +%T`: Installation abgeschlossen."
echo
# *** EOF ***