import re
from collections import namedtuple
from itertools import zip_longest

t = '''
X:1
   a "Am7" B C D E    | "G" D E f g
w: 1. this is lit-tle | text for me. _
w: 2. a-no-ther one | which will kill thee.
'''

HEADPAT = re.compile(r'^(\w)\s*:\s*(.*)$')
NOTEPAT = re.compile(r'(?P<note>[abcdefgbABCDEFGB][,]?)(?P<duration>\d*)|"(?P<chord>\w+)"')
SPCPAT  = re.compile(r'[\s|]+')
TEXTPAT = re.compile(r'([^\s-]+)\s*(\-?)')

# Our ABC 'AST'
Header = namedtuple('Header', ('name', 'content'))
Notes  = namedtuple('Notes',   ('elems',))
Text   = namedtuple('Text',   ('elems',))

# 'Text' may contain:
Textpart = namedtuple('Textpart', ('text', 'split'))

# 'Note' may contain:
Note   = namedtuple('Note',   ('name', 'duration'))
Chord  = namedtuple('Chord',  ('name',))



def lex(value_pattern, space_pattern, line):
    begin = line
    while len(begin) > 0:
        m = re.match(value_pattern, begin)
        if m:
            yield m
            begin = begin[m.end(0):]
        else:
            m = re.match(space_pattern, begin)
            if m:
                begin = begin[m.end(0):]
            else:
                raise RuntimeError(f"format did not match {line}")


def parse_abc(lines):
    for line in lines:
        # Header line
        m = re.match(HEADPAT, line)
        if m:
            name, content = m.groups()
            if name == 'w':
                elems = []
                for m in lex(TEXTPAT, SPCPAT, content):
                    cont = m.group(2) != ''
                    if m.group(1) != '|':
                        elems.append(Textpart(m.group(1), cont))
                # parse text
                yield Text(elems)
            else:
                yield Header(name, content)
        else:
            # lex a note line
            elems = []
            for m in lex(NOTEPAT, SPCPAT, line):
                if m.group('note'):
                    elems.append(Note(m.group('note'), m.group('duration')))
                elif m.group('chord'):
                    elems.append(Chord(m.group('chord')))
            yield Notes(elems)


def note_with_cord(noteline):
    lastchord = None
    for n in noteline:
        if isinstance(n, Chord):
            lastchord = n
        else:
            yield (n, lastchord)
            lastchord = None


def make_chordsheet(lines):
    lastnotes = None
    for e in parse_abc(lines):
        if isinstance(e, Notes):
            lastnotes = e.elems
        elif isinstance(e, Text) and lastnotes:
            chordline = ''
            textline = ''
            rest = 0 # > 0 when chordlen > lenght of text part
            
            for idx, n in enumerate(note_with_cord(lastnotes)):
                text     = e.elems[idx]
                note     = n[0]
                chord    = n[1]
                textlen  = len(text.text)
                chordlen = len(chord.name) if chord else 0

                if chord:
                    chordline += chord.name
                    if chordlen < textlen:
                        chordline += ' ' * (textlen - chordlen - rest)
                        rest -= textlen - chordlen
                else:
                    chordline += ' ' * (textlen - rest)
                    rest -= textlen 

                if rest < 0 :
                    rest = 0

                textline += text.text 

                if not text.split:
                    textline  += ' '
                    chordline += ' '
                else:
                    if rest == 0 and chordlen > textlen:
                        #textline += '_' * (chordlen - textlen)
                        rest = (chordlen - textlen)



            yield chordline, textline


for chordline, textline in make_chordsheet(t.splitlines()):
    print(f'.{chordline}')
    print(f' {textline}')
