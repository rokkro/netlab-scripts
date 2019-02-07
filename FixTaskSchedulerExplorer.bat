REM Launches explorer since a scheduled task fails to do so.
net stop "Task Scheduler"
C:\Windows\explorer.exe
net start "Task Scheduler"
