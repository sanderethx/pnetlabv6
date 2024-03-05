@echo off
 SET input=%1
 FOR /f "tokens=1,2,3 delims=:" %%a IN ("%input%") do SET host=%%b&SET port=%%c
 SET host=%host:~2%
 start "" /D "C:\Program Files (x86)\Mobatek\MobaXterm" MobaXterm.exe -newtab "telnet -r %host% %port%"
