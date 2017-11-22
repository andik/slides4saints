@echo off
::
:: this script does generate the windows batch files for all
:: those scripts in 'bin'
::

setlocal

pushd %~dp0\..\bin

call :batfiles_for_type "exec wish"  wish86.exe
call :batfiles_for_type "exec tclsh" tclsh86.exe

goto :eof

:: ------------------------------------------------------------------

:batfiles_for_type

for %%i in (s4s-*) do (
	:: check that we only use the executables, not the bat files
	if "%%~xi"=="" (
		type %%i | find %1 >nul
		if not errorlevel 1 (
			echo %2 %%i 
			call :makebat %2 %%i
		)
	)
)

goto:eof

:: ------------------------------------------------------------------

:makebat

echo @echo off > %2.bat
echo call %%~dp0\s4s-env.bat >> %2.bat
echo %1 %%~dp0\%2 %%* >> %2.bat 

goto:eof
