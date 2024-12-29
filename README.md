# SvxLink_RepeaterLogic_de
German RepeaterLogic for SvxLink Repeater Controller
Deutsche Ablaufsteuerung für SvxLink

## Beschreibung

SvxLink liefert bereits "ab Werk" eine RepeaterLogic mit. Diese ist jedoch nicht gerade optimal an die deutschen Verhältnisse angepasst. Darüber hinaus hat es mich immer gestört, für jedes der von mir betreuten Relais in die Tc.Routinenen eingreifen und dort Anpassungen machen zu müssen. Daher habe ich, eher aus einer Bequemlichkeit, mit dieser Tcl begonnen und stelle sie nun allen Interessierten zur Nutzung bereit.

Was kann das Dingen?
* Kennung zu Beginn und zum Ende eines QSO sowie alle n Minuten (AFuV-konform wäre mindestens alle zehn Minuten)
* Stille bei deaktiviertem Relais
* Einstellung aller Tonhöhen für Kennungen und Rogerbeep
* Ansage der Kennung mittels eigener Audio-Datei oder Buchstabiierung
* CW-Kennung mittels eigener Audio-Datei oder Code-Ausgabe
* optionale Ansage von CTCSS-Subton mittels vordefinierter oder eigener Ansage
* freie Wahl von nur CW-Kennung, nur Ansage oder beidem in verschiedenen Reihenfolgen
* eigene Locale.tcl zur korrekten Anpassung der Ansagen, z.B. bei Uhrzeit
* wahlweise Uhrzeitansage
* Festlegung aller Parameter mittels eigener Konfigurationsdatei
* alle Einstellungen ohne Eingriff in die Tcl, keine Programmier- und Update-Kenntnisse erforderlich
* jederzeit update-fähig

Ich gebe zu, dass ich selbst nicht alle möglichen Parametrisierungen getestet habe, weil sie für mich nicht infrage kamen. Sollten Fehler auftreten, freue ich mich über einen Hinweis mit möglichst genauer Beschreibung, so dass ich das Problem beheben kann.

Ferner garantiere ich natürlich für absolut gar nichts! Einsatz der hier angebotenen Dateien auf absolut eigene Gefahr. Sollte das Relais nach dem Einspielen seltsame Dinge tun, ein Eigenleben entwickeln oder schmutzige Lieder singen, habe ich nix damit zu tun.

## Installation

1. Falls noch nicht vorhanden, git installieren (wenn SvxLink installiert ist, sollte dieses bereits vorhanden sein):

```
$ apt-get update && apt-get upgrade
$ apt-get install git
```

2. Aktuelle Version dieses Pakets aus dem git laden:

```
$ git clone https://github.com/do6np/svxlink_repeaterlogic_de.git
```

3. Verzeichnis wechseln und Installations-Skript ausführbar machen:

```
$ cd svxlink_repeaterlogic_de
$ chmod +x install.sh
```

4. Skript starten:

```
$ ./install.sh
```

5. Parameter anpassen, siehe folgende Kapitel.

## Konfiguration

### Bearbeitung

Nach der Installation des Pakets werden alle Einstellungen zum Relais in der Datei /etc/svxlink/svxlink.d/repeater.conf bzw. /usr/local/etc/svxlink/svxlink.d/repeater.conf (je nach Installation) vorgenommen. Eine Bearbeitung ist z.B. mit diesem Kommando möglich:

```
$ sudo nano /etc/svxlink/svxlink.d/repeater.conf
```

### Parameter

Im Folgenden werden alle Parameter der repeater.conf kurz besprochen:

Folgende Parameter sind bereits in SvxLink enthalten:
* __[RepeaterLogic]__ leitet die Konfiguration des Repeaters ein. Sollte in der svxlink.conf ein anderer Name für die Logic definiert sein (z.B. RepeaterXY), so muss dieser Name identisch sein.
* __SHORT_VOICE_ID_ENABLE__ - Soll bei der kurzen ID (i.d.R. alle zehn Minuten) eine Sprachansage ausgegeben werden?
* __SHORT_CW_ID_ENABLE__ - Soll bei der kurzen ID (i.d.R. alle zehn Minuten) eine CW-Kennung ausgegeben werden?
* __SHORT_ANNOUNCE_ENABLE__ - Soll bei der kurzen ID (i.d.R. alle zehn Minuten) eine spezielle Informationsdatei ausgegeben werden?
* __SHORT_ANNOUNCE_FILE__ - Name und Pfad der Datei (siehe vorherigen Punkt).
* __LONG_VOICE_ID_ENABLE__ - Soll bei der langen ID (i.d.R. alle 60 oder 30 Minuten) eine Sprachansage ausgegeben werden?
* __LONG_CW_ID_ENABLE__ - Soll bei der langen ID (i.d.R. alle 60 oder 30 Minuten) eine CW-Kennung ausgegeben werden?
* __LONG_ANNOUNCE_ENABLE__ - Soll bei der langen ID (i.d.R. alle 60 oder 30 Minuten) eine spezielle Informationsdatei ausgegeben werden?
* __LONG_ANNOUNCE_FILE__ - Name und PFad der Datei (siehe vorherigen Punkt).
* __CW_AMP__ - Amplitude der CW-KEnnung
* __CW_PITCH__ - Tonhöhe der CW-Kennung in Hz, Kommawerte möglich.
* __CW_CPM__ - Geschwindigkeit der CW-KEnnung in Zeichen pro Minute.
* __CW_WPM__ - Alternativ: Geschwindigkeit der CW-KEnnung in Wörter pro Minute.

Folgende Parameter wurden für die SvxLink_RepeaterLogic_de neu eingeführt:
* __RGR_SOUND_AMP__ - Amplitude des Rogerbeeps.
* __RGR_SOUND_PITCH__ - Tonhöhe des Rogerbeeps in Hz, Kommawerte möglich.
* __RGR_SOUND_CPM__ - Geschwindigkeit des CW-Rogerbeeps in Zeichen pro Minute.
* __RGR_SOUND_TONELENGTH__ - Länge des Rogerbeeps in Millisekunden, wenn kein CW-Rogerbeep verwendet wird.
* __RGR_SOUND_RX_ID__ - Soll die ID des Empfängers ausgewertet werden, siehe nächsten Punkt.
* __CW_FIRST__ - Soll zuerst die CW-Kennung ausgegeben werden? Wenn nein, wird zuerst die Sprachansage ausgegeben und dann folgt CW.
* __SHORT_VOICE_ID_MODULE__ - Soll bei der kurzen ID ein evtl. aktives Modul wie z.B. EchoLink angesagt werden?
* __LONG_VOICE_ID_TIME__ - Soll bei der langen ID eine Zeitansage erfolgen?
* __LONG_VOICE_ID_MODULE__ - Soll bei der langen ID ein evtl. aktives Modul wie z.B. EchoLink angesagt werden?

### Die Sache mit dem Piep

Die SvxLink_RepeaterLogic_de kennt zwei Varianten, wie ein Rogerbeep ausgegeben werden kann.

Variante eins ist die einfachste: ein Empfänger, ein Rogerbeep. In diesem Fall werden die Werte für RGR_SOUND_AMP, RGR_SOUND_PITCH und RGR_SOUND_TONELENGTH ausgewertet. RGR_SOUND_RX_ID muss auf 0 stehen oder auskommentiert sein.

Variante zwei ist dann interessant, wenn das Relais mehrere Empfänger besitzt und für jeden dieser Empfänger ein eigener Buchstabe als Rogerbeep ausgegeben werden soll. Dann kann RGR_SOUND_RX_ID=1 gesetzt werden. Bei jedem Empfänger in der svxlink.conf muss dann der dort bereits vorhandene Parameter RX_ID mit dem Buchstaben des Empfängers aktiviert werden. So könnte z.B. für einen RX auf VHF TX_ID=V eingestellt werden. In der repeater.conf werden dann die Werte von RGR_SOUND_AMP, RGR_SOUND_PITCH und RGR_SOUND_CPM ausgewertet.

## Audio-Dateien

### Ort der Dateiablage

Unter /usr/share/svxlink/sounds/LANG liegen die Sprachdateien der SvxLink-Installation, wobei LANG durch die jeweilige Sprache zu ersetzen ist (z.B. /usr/share/svxlink/sounds/de_DE). Dort muss ein Ordner Namens "LocalAudio" (Schreibweise beachten) angelegt werden. Dies geht z.B. mit folgendem Befehl:

```
$ sudo mkdir /usr/share/svxlink/sounds/de_DE/LocalAudio
```

Anschließend können alle gewünschten Dateien dort hineinkopiert werden.

Näheres zu den Dateien ist in der SvxLink-Dokumentation zu finden.

### Liste der Dateien

Folgende Dateien können angelegt werden und werden bei Vorhandensein automatisch abgespielt:

* __MYCALL__ - Sobald eine Datei existiert, die genauso heißt wie das unter CALLSIGN angegebene Rufzeichen in der svxlink.conf, wird diese immer dann abgespielt, wenn das eigene Relais-Rufzeichen ausgegeben werden soll. Wichtig ist, dass alle Buchstaben grossgeschrieben sind, wenn dies auch bei der Angabe von CALLSIGN der Fall ist, was dem Standard entspricht. Beispiel: DB0ABC.wav
* __MYCALL_cw__ - Eigene CW-Kennung anstelle der vom Relais erzeugten. Beispiel: DM0ABC_cw.wav
* __LINKNAME__ - Wenn man das LogicLinking benutzt, kann man anstelle des Buchstabierens eine Datei mit dem Namen des Links erstellen. Die Schreibweise inkl. Groß- und Kleinschreibung muss dem entsprechen, was in der svxlink.conf unter CONNECT_LOGICS angegeben ist. Beispiel: NordWestLink.wav
* __ctcss__ - Diese Datei wird anstelle der Ansage des Subtons mittels vordefinierter Bausteine abgespielt.
* __clock__ - Z.B. ein Uhrengeräusch anstelle der Ansage "Es ist jetzt".
* __ein__ - Das Wort "ein" wie in "ein Uhr". Fehlt es, wird es durch die normale "eins" ersetzt.
* __idle__ - Wenn unter IDLE_SOUND_INTERVAL ein Wert eingestellt ist, der kleiner ist als der Wert von IDLE_TIMEOUT, und der Wert von IDLE_SOUND_INTERVAL nicht 0 ist, dann gibt SvxLink einen Idle-Sound aus. Dieser Sound kann mit dieser Datei festgelegt werden. Ist kein Sound vorhanden, wird ein "K" für "Kommen" in CW ausgegeben.
* __uhr__ - Das Wort "Uhr" für die Uhrzeitansage. Fehlt es, wird es weggelassen.

## Updates

Normalerweise sollte es kein Problem darstellen, SvxLink regelmäßig zu aktualisieren. Sollte Tobias, SM0SVX, größere Änderungen an Logic.tcl, RepeaterLogic.tcl und Co. vornehmen, kann allerdings eine Anpassung von SvxLink_RepeaterLogic_de notwendig werden. Ich empfehle daher, nach einem SvxLink-Update jeweils auch dieses Paket aus git zu aktualisieren.

## Kontakt

Bei weiteren Fragen, Anregungen...
E-Mail: <do6np@amateurfunk-osnabrueck.de>