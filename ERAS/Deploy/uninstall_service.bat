@echo off
echo Stopping and removing ERAS service...
net stop ERAS
sc delete ERAS
echo Done.
pause
