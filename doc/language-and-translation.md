# Languages and Translation support

because music is written worldwide and in different languages, S4S has support
for songs written/translated in different languages.  S4S can also show
translated text right below a song text in the language in which it's sung.

In the S4S section format we can therefore have multiple versions of the same
line standing right below:

    eng Blessed be Your name, 
    de Gepriesen sei dein Name 

The first word is *always* (!) the language. the following words is the line of
the song which shall be displayed in a single line on the screen.

Now it's up to S4S to choose between that different versions of the song and to
use them properly.

## Selection Songs language and translation

the song's native language is supplied in the songs property `language`. If this
property is not set the configuration variable `S4S_LANG` is used as default
language.

With the setlist parameter `language` the native language of any song can be
changed to be another. p.e. this way you may switch between a song sung in a
native and in a translated version.

so the language is selected as follows:

1. configuration option `S4S_LANG`
2. overriden by song property `language`
3. overriden by setlist parameter `language`

the same applies to the song property/setlist parameter `translation` which
allows one to display a translation below the presented song text lines.
A default can be given by the configuration options `S4S_TRANSLATION`

## Typical setup for non-native-english speakers

often a lot of worship songs in english are sung beside songs in the native
language of a church. For thess songs one may want to display a translation.
Here is the typical setup:

For all songs you want to display ensure the `language` property is set
correctly. Set your `S4S_LANG` configuration to `eng` and your `S4S_TRANSLATION`
config to you native language (in my case `de`).

Now songs wich are english and have a `de` annotation (your your langauge)
inside, are displayed with translation while songs in your language are
displayed without translation. 

## Typical setup for multi-language churches

Specify the `language` and the `translation` property in each song. The
`translation` property is the default translation for a song. if you want to
change the language of the song for p.e. one service simply specify `language`
and `translation` setlist options.

