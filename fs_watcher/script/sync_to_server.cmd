@ECHO OFF
REM Make environment variable changes local to this batch file
SETLOCAL

REM ** CUSTOMIZE ** Specify where to find rsync and related files (C:\CWRSYNC)
REM SET CWRSYNCHOME=%PROGRAMFILES%\CWRSYNC

REM Set HOME variable to your windows home directory. That makes sure 
REM that ssh command creates known_hosts in a directory you have access.
SET HOME=%HOMEDRIVE%%HOMEPATH%

REM Make cwRsync home as a part of system PATH to find required DLLs
SET CWOLDPATH=%PATH%
SET PATH=.\cwRsync;%PATH%

REM ** CUSTOMIZE ** Enter your rsync command(s) here --chmod 0777

rsync -avz -u -d -r -h -pgo --chmod 0700 --del -e "ssh  -i %1" --itemize-changes  --exclude-from="config/rsync_exclude.config" %2 %3@%4:%5
