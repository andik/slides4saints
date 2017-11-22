# S4S Installation

## Prequisites

- slides4saints requires `TCL/TK` of at least version 8.6.

### Posix Based Systems
- use your package manager to install tcl/tk with at least version 8.6

### Mac OS
- the TCL/TK provided by OSX is outdated. Use ActiveTCL 8.6 TODO Link 

### Windows
- When you use a release version all prequisites are provided within the package
- When you clone the git repository you need to either install ActiveTCL8.6 or the s4s-runtime.

**Important Notice** in these times it is not trivial to use binaries because of every one wants to hack your computer. The required TCL/TK binaries which are supplied by the S4S project for windows, are extracted from the MSYS-Git Package which does in turn use the MSYS2 Packages which are build by private persons. There can be no guarantee for the not to contain dangerous stuff (especcially as a Runtime like TCL/TK is pretty generic). I have applied some virus scanners on the s4s-runtime, but this does not necessarily mean the these binaries are clean. WE PROVIDE NO WARRANTY FOR THEM.

## Setup S4S

1. Extract the `s4s.zip` archive into a custom directory

    * this directory will be referred in this document as "S4S directory"

2. All other required setup is done on your computer when you start s4s for the first time. So

    * on windows run `s4s.bat`
    * on posix run `s4s.sh` (in a terminal)
    * on mac run `S4S.app`

When you startup S4S you are questioned some questions which are explained below.

### Step 1: Data Directory

S4S uses a special `data`-directory to store songs, setlists, bibles, images etc..
This is the directory which should be kept in sync between the computers of your church and all people who use S4S (i.e. musisians etc.).

**Important** When your church/band already has setup such a directory on a service like dropbox/github etc. you first need to get/sync that directory before continuing. Ask your friends when in doubt how to set that up.

Within the "Data Directory" Dialog do one of the three
1. select the data directory which you sync'd/got from your church/band
2. select the `demo-data` directory within the S4S Directory
3. create an empty folder and select this directory

### Step 2. S4S User name

S4S requires a user name to be set up. this may not seems logical at first, but allows any musician to have his own set chord sheets. So provide a user name or use the "default" user name when prompted.

### Step 3 S4S Manager

after setup the S4S Manager is run. This is the command-central of Slides4Saints. If you have chosen the demo data directory or another data directory with content you should now see a list of songs or sets...

You can now go to the next chapter.
