REM Launches explorer since a scheduled task fails to do so.
net stop "Task Scheduler"
EXPLORER
net start "Task Scheduler"
