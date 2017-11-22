@echo off
::
:: this script does the setup of the environment for S4S
::
:: as S4S is written like a posix program, with a lot of small parts
:: we need to "glue" these parts together using the environment...
:: this is done here, mostly by setting up environment variables correctly
::

if "%S4S_USER%"=="" call:setup_user

:: override path to use our internal binaries...
set PATH=%~dp0;%~dp0\msys\bin;%~dp0\usr\bin;%PATH%

:: the language to display
set S4S_LANG=eng
set S4S_TRANSLATION=de

:: create the data dir variable if not set
:: this variable defines where the S4S Data is stored.
if "%S4S_DATA_DIR%"=="" (
	setx S4S_DATA_DIR "%~dp0\..\data"
	set S4S_DATA_DIR=%~dp0\..\data
)

if "%S4S_LIB_DIR%"=="" (
	set S4S_LIB_DIR=%~dp0\..\lib
)

:: Song Editor
set S4S_SONG_EDIT_FONT=Source Code Pro
set S4S_SONG_EDIT_SIZE=10

:: display configuration options
set S4S_DISPLAY_FONT_SIZE_SCALE=0.95
set S4S_DISPLAY_FONT_SIZE_MIN=10
set S4S_DISPLAY_FONT_SIZE_MAX=50


set S4S_DISPLAY_BG_COLOR=#200
set S4S_DISPLAY_TEXT_COLOR=#fff
set S4S_DISPLAY_SUBTEXT_COLOR=#ccc

set S4S_DISPLAY_SUBTEXT_SCALE=0.7

set TCLLIBPATH=%TCLLIBPATH% %S4S_LIB_DIR:\=/%/tcl

goto:eof


:::::::::::::::::::::::::::::::::::::::
:setup_user
:::::::::::::::::::::::::::::::::::::::

color f0
echo no username set up for this Slides4Saints instance.
echo enter username for this account. We will install the
echo environment variable 'S4S_USER' to set the users name
echo/

set /P "S4S_TMPUSER=Username? "

echo Setze '%S4S_TMPUSER%' als Slides4Saints Nutzer.
setx S4S_USER %S4S_TMPUSER%
set S4S_USER=%S4S_TMPUSER%

goto:eof