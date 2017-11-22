# S4S configuration

**Important** please see `architecture.md` if you want to understand how s4s works, which may be usefull for the configuration.

## How S4S is configured

S4S is currently configured using environment variables. These may be either setup by your computer or local in `s4s-env.bat` / `s4s-env.source` files in the `bin` directory in s4s.

there is no colorful configuration dialog yet, not even a configuration file, because I simply did not have the time to create one. contributions are welcome.

## Reference

* `S4S_DATA_DIR` points to the slides4saints data directory
* `S4S_USER` sets the name of the user (mostly for the sheets viewer)
* `S4S_EDITOR` or `EDITOR` sets the editor which is used with the "edit extern" buttons
* `S4S_DISPLAY_BG_COLOR` background color of the song presentation window. **there is no background-image support yet**
* `S4S_DISPLAY_FONT_SIZE_MAX` maximum font size of the presentation display
* `S4S_DISPLAY_FONT_SIZE_MIN` minimum font size of the presentation display. text which is too large for the window with the minium font size will be clipped which hides the text and looks ugly...
* `S4S_DISPLAY_FONT_SIZE_SCALE` maximum width or height of the displayed text relative to the display width/height. range 0...1. Make smaller for larger borders around the text.
* `S4S_DISPLAY_SUBTEXT_COLOR` color of translations
* `S4S_DISPLAY_SUBTEXT_SCALE` defines font size of translations/subtexts. Is multiplied with the main fontsize, which is dynamically calculated. So a number between 0.5...1 seems a good choice. 
    "translation font size" = "main text font size" x "S4S_DISPLAY_SUBTEXT_SCALE" 
* `S4S_DISPLAY_TEXT_COLOR` normal text color for presented songs
* `S4S_LANG` main language for most songs
* `S4S_TRANSLATION`main translation language for most songs.
* `S4S_SONG_EDIT_FONT` font family for song editor (section text editor)
* `S4S_SONG_EDIT_SIZE` font size for song editor (section text editor)

 
## Site dependend

these are the options which are important for your  
