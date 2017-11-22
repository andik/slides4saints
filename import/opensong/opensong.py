# -*- coding: utf-8 -*-

'''
OpenSong Song Importer 

Converts opensong files into slides4saints json files.

usage: opensong.py <opensong-file>

outputs converted text to json.

can also be imported as module

'''

from lineparser import LineOrientedParser
import xml.etree.ElementTree as ET
import re, os, os.path
import os.path as path
import quopri
import codecs
import sys

# python has no good encoding for song names, we need to make out custom one
#

class TranslateFn(object):
    mapping = {
        ' ':  '-',
        '\t': None,
        ',':  None,
        '#':  '-',
        'ü': 'ue',
        'Ü': 'Ue',
        'ä': 'ae',
        'Ä': 'Ae',
        'ö': 'oe',
        'Ö': 'Oe',
        'ß': 'ss'
    }

    def __getitem__(self, o):
        c = chr(o)
        if c in self.mapping:
            return self.mapping[c]
        else:
            raise LookupError()


# change opensong section names to our own.
def fix_secname(secname):
    secname = secname.replace(' ', '-')
    return re.sub(r'[vV](\d)+', r'\1', secname).strip().lower()


# name output file correctly
def fix_basename(basename):
    return re.sub(r'[^a-zA-Z0-9_\-]+', '-', basename).lower() + '.s4s-song'


class OpenSongLyricsParser(LineOrientedParser):
    # Patterns used in the Parser #

    # line is a section
    pat_section = re.compile(r'^\[(.+?)\]')
    # parsing one 'C    ' chord section on a chord line or 
    # emptyness until the next chord
    pat_chordssec   = re.compile(r'([\w\d/\\|\-\#\+\(\)]*)(\s+|$)') 
    # verse line with section
    pat_versewithsec = re.compile(r'\d+')

    def __init__(self, text, language="eng"):
        super().__init__(text)
        self.language = language


    def parse(self):
        # Stores the sections: is dict of section name -> list (with section's text parts and commands)
        self.sections = {}

        # current chord line
        self.curchordline = None
        # current section
        self.cursection = None

        linenum = 0

        while self.haslines():
            # process a new Input line
            line = self.read_line()
            linenum += 1


            if not line: break

            # is the line a sections
            section_match = self.pat_section.match(line)
            # is it a line with prefixed number
            versewithsec_match = self.pat_versewithsec.match(line)

            # empty line: delete chords
            if len(line.strip()) == 0:
                self.curchordline = None

            # section line - cursection is the matching list in the sections dict
            elif section_match:
                sec = self.register_section(section_match.group(1))

                # if valid section: this is the next section
                if sec != None:
                    self.cursection = sec

                # a section starts without chords
                self.curchordline = None

            # text line with section in it.
            elif versewithsec_match:
                sec = self.register_section(versewithsec_match.group(0))
                self.text_line(line, sec)

            # chord line
            elif line.startswith('.'):
                self.curchordline = line[1:]

            # text line - no verse line
            elif line.startswith(' '):
                self.text_line(line, self.cursection)

            # TODO: comment line
            elif line.startswith(';'):
                pass


        return self.sections

    def parse_line_with_chords(self, chordline, line):
        parts = []

        chordlen = len(chordline)
        linelen = len(line)

        # bring chord line and text line to the same length
        if chordlen < linelen:
            chordline += " " * (linelen - chordlen)
        elif linelen < chordlen:
            line += " " * (chordlen - linelen)

        for m in re.finditer(self.pat_chordssec, chordline):
            # m matches now a chord section

            # add text part and chordline
            parts += self.line_to_parts(line[m.start():m.end()], m.group(1))

        return parts

    def register_section(self, secname):
        secname = fix_secname(secname)

        # ignore opensong "v" sections
        if secname == "v": 
            return None

        if not secname in self.sections:
            self.sections[secname] = []

        return self.sections[secname]

    def text_line(self, line, sec):
        if self.curchordline:
            linedata = self.parse_line_with_chords(self.curchordline, line[1:])
            self.curchordline = None
        else:
            linedata = self.line_to_parts(line[1:])

        if sec == None:
            sec = self.register_section('_notes')
            print('-> text without section found, storing in "_notes"', file=sys.stderr)

        # add the generated data to the section
        sec += linedata

        # each text line in opensong cause a linebreak in s4s
        if len(sec) > 0 and sec[-1] != {"!": "/"}:
            sec.append({"!": "/"})

    # searches text for opensong special chars add the matching commands if necessary
    def line_to_parts(self, line, chord=None):

        # format line whitespace
        line = re.sub(r'\s+', ' ', line)
        line = re.sub(r'_+', '', line)

        for tok in re.split(r'(\|\||\|)', line):
            if tok == "":
                continue
            # empty line
            elif tok == '|':
                yield {"!": "//"}
            # new slide
            elif tok == '||':
                yield {"!": "-"}
            else:
                tok = re.sub(r'\s+', ' ', tok)
                if chord:
                    yield {'#c': chord, self.language: tok}
                else:
                    yield {self.language: tok}


class OpenSongImporter:
    # import Opensong XML Entries which describe the song 
    keys = {
        'title':           'title',
        'author':          'author',
        'copyright':       'copyright',
        'hymn_number':     'hymn_number',
        'ccli':            'ccli',
        'capo':            'capo',
        'key':             'key',
        'user1':           'maintainer',
        'tempo':           'tempo',
    }
    
    def __init__(self, filename, tree, language="eng"):
        root = tree.getroot()

        # output json data
        self.data = {}

        # default Language
        self.language = language

        # set default language in song
        self.data["langs"] = [language]


        # find Keys in XML and convert to S4S key and store in data
        for oskey, s4skey in list(self.keys.items()):
            path = "./{}".format(oskey)
            node = root.find(path)
            if node != None and node.text != "" and node.text != None:
                self.data[s4skey] = node.text
                #print(s4skey, node.text)

        # mark we're from opensong
        self.imported_from = "opensong"

        # read the lyrics text
        lyricsnode = root.find('./lyrics')
        # ERROR: if no lyricsnode was found, this is a critical error
        if lyricsnode == None: 
            raise RuntimeError("No Lyrics found in Opensong file")
        
        # we'll output the imported text in the output as comment
        #print( '/* Open Song Imported Lyrics are\n' + lyricsnode.text  +'\n*/') 

        # use the lyricsparse to make data from Opensong Song Format
        lyricsparser = OpenSongLyricsParser(lyricsnode.text, self.language)
        # store the parsed sections in data
        try:
            self.data['sections'] = lyricsparser.parse()
        except Exception as e:
            print(lyricsnode.text)
            raise e

        # read ordering
        ordernode = root.find('./presentation')
        
        # ERROR: if no ordernode was found, we use a straigt ordering
        if ordernode == None: 
            order = list(self.data['sections'].keys())
        else:
            # make the ordering array
            if ordernode.text != None:
                # replace "verse marker of opensong"
                order = list(fix_secname(s) for s in 
                             re.split(r'\s+', ordernode.text.strip().lower()))
            else:
                order = list(sorted(self.data['sections'].keys()))



        self.data['ordering'] = order


# old JSON format, keep for reference
def convert_to_json(filename, outfile, args):

    if args.verbose:
        print((filename + ' -> ' + args.output))

    try:
        tree = ET.parse(filename)
    except:
        print("error while reading opensong xml file", filename, file=sys.stderr)
        return

    try:
        obj = OpenSongImporter(filename, tree, args.language)
    except:
        return

    with open(outfile, 'w') as f:
        json.dump(obj.data, f, indent=2)


def s4s_filename(title):
    fn = title #.lower()
    fn = fn.translate(TranslateFn())
    return fn


def convert_to_s4s(filename, outdir, args):
    '''
        convert from the original JSON format
        to s4s format...

        it's an ugly mess... it was quite late... but it works
    '''

    print('process', filename)

    try:
        tree = ET.parse(filename)
    except:
        print("error while reading opensong xml file", filename, file=sys.stderr)
        return

    obj = OpenSongImporter(filename, tree, args.language)

    # try:
    #     obj = OpenSongImporter(filename, tree, args.language)
    # except:
    #     print("error while parsing file", filename, file=sys.stderr)
    #     return

    # directory where to store the data
    # try:
    d = path.join(outdir, s4s_filename(obj.data['title']) + '.s4s-song')
    # except:
        # print("error generating filename for", filename, file=sys.stderr)
        # return
    
    if not os.path.exists(d):
        os.makedirs(d)

    # Directory for Song Attachments
    attachments_dir = path.join(d, 'attachments')
    if not os.path.exists(attachments_dir):
        os.makedirs(attachments_dir)    

    #ordering
    with codecs.open(path.join(d, 'order.s4s-song-property'), 'w', encoding='utf-8') as f:
        f.write(' '.join(obj.data['ordering']))

    # song-title
    with codecs.open(path.join(d, 'title.s4s-song-property'), 'w', encoding='utf-8') as f:
        f.write(obj.data['title'])

    # song-language
    with codecs.open(path.join(d, 'language.s4s-song-property'), 'w', encoding='utf-8') as f:
        f.write(obj.language)

    # song-title
    for key in obj.keys:
        if key in obj.data:
            with codecs.open(path.join(d, key+'.s4s-song-property'), 'w', encoding='utf-8') as f:
                f.write(obj.data[key])

    # because we've written the OpenSongLyricsParser to create JSON we need to
    # can easily convert that to ChordPro Format
    for secname, secdata in list(obj.data['sections'].items()):
        newline = True

        # do not store empty sections which are not listed in ordering
        if len(secdata) == 0 and secname not in obj.data['ordering']:
            continue

        outfn = path.join(d, secname+'.s4s-song-section')
        with codecs.open(outfn, 'w', encoding='utf-8') as f:

            for entry in secdata:
                if '!' in entry:
                    
                    # line-break
                    if entry['!'] == '/':
                        f.write('\n')
                        newline = True
                    elif entry['!'] == '//':
                        f.write('empty')
                    elif entry['!'] == '-':
                        f.write('\nslide\n')
                    else:
                        print('unknown command:', entry['!'], file=sys.stderr)

                else:
                    if newline:
                        f.write(obj.language)
                        f.write(' ')
                        newline = False

                    if '#c' in entry:
                        f.write('[{}]'.format(entry['#c']))

                    f.write(entry[obj.language])

if __name__=="__main__":
    # Parse Arguments
    import json
    import argparse
    parser = argparse.ArgumentParser(description='convert opensong file into slides4saints json')
    o = parser.add_argument    
    o('file', type=str, nargs='?', help='file or directory to import')
    o('-l', '--language', type=str, help='language of song', default="eng")
    o('-o', '--output', type=str, help='output file or directory', default='.')
    o('-s', '--set', action='store_true', help='import set, not song')
    o('-v', '--verbose', action='store_true', help='verbosity')
    args = parser.parse_args()

    # Parse input file and dump data to STDOUT
    if not os.path.isdir(args.file):
        #convert_to_json(args.filename, args.output, args)
        convert_to_s4s(args.file, args.output, args)
    else:
        join = os.path.join
        relpath = os.path.relpath

        for root, dirs, files in os.walk(args.file):
            if args.output:
                outdir = join(args.output, relpath(root, args.file))
            else:
                outdir = '.'

            if not os.path.exists(outdir):
                os.makedirs(outdir)

            for basename in files:
                if basename.startswith('.'): 
                    continue

                fn = join(root, basename)
                #outbasename = fix_basename(basename)
                
                #outfn = join(outdir, outbasename)

                convert_to_s4s(fn, outdir, args)

        

