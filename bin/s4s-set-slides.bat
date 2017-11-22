@echo off
set PATH=%~dp0
set S4S_DATA_DIR=%~dp0\..\data
%~dp0\msys\bin\tcl86.exe %~dp0\s4s-control
