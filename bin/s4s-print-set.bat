@echo off 
call %~dp0\s4s-env.bat 
tclsh86.exe %~dp0\s4s-print-set %*  
