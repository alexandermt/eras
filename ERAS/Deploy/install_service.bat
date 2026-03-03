@echo off
echo Installing ERAS as Windows Service...
sc create ERAS binPath= "%~dp0bin\ERAS.exe /service" DisplayName= "ERAS - Enterprise Ranking & Admissions System" start= auto
sc description ERAS "Enterprise Ranking and Admissions System (UniGUI)"
echo Done. Start with: net start ERAS
pause
