# slides4saints

this is a program to aid both churches and worship bands to display their song texts during an service and also manage their songs/sets. 

**IMPORTANT** the current version of slides4saints is just for internal testing
purposes. it is not ready to use yet.
We arbitrary set some environment variables for windows and supply you with some unchecked
binaries for windows... this will change in the next weeks...

## why slide4saints?

There are a lot of such programs out yet, so why another one?

- does chordsheets
- printing sheets made easy
- songs can easily have attachments (records, note-sheets, videos)
- Keyboard oriented song display controlling
- it's small (written in tcl/tk)
- it's portable (no installation)
- plain-text and filesystem only storage
    + working very well with git/dropbox etc.
- storage format is very easy to understand and hack on. 
    + a song is a folder
    + shell-script optimised line oriented format for song sections
- each small part of the system is a standalone program
    + easy to understand
    + easy to exchange by your own implementation 
        * e.g. want more effects on the display or want to run the display on a different computer? it's dead simple to implement your own.
- thus it's pretty easy to hack on, to extend and to adapt to your local requirements

## Known issues

- printing songs has some incorrect space mapping...

## Todo

- until version 1.0
    + common os indepenedent configuration file
    + properly tested on osx, posix and windows.
    + note sheet editor 
        - integration and use of chord sheets inside
        - simple color selection
        - ABC Note rendering for Solo Parts etc.
    + bible verse display
    + simple text slides
    + messages during service
    + presentation spontaneous song/verse loading
    + create a github repository
- until version 2.0
    + display styles other than background color (at least images)
    + settings dialog
    + Sync between SheetViewer and Presentation

## why TCL?

- easy to distribute cross platform applications
- aside: http://beauty-of-imagination.blogspot.de/2016/01/tcltk-vs-web-we-should-abandon-web.html

