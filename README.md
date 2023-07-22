# PRTG-Epson-ecotank-maintenance-box-monitor
PRTG sensor to monitor Epson ecotank maintenance box / waste box level
By lookup from webinterface as this value in not provided in SNMP

To use

Copy .ps1 file to  \Custom Sensors\EXEXML

Then Add Sensor > select "EXE/Script Advanced" sensor type.

In the "Settings" tab, configure the following:

EXE/Script: Select .ps1 file

Parameters:

`-url "https://[PRINTER_IP]/PRESENTATION/ADVANCED/INFO_PRTINFO/TOP"`
