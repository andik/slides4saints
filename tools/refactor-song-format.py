import re
import os
import os.path
from pathlib import Path


for root, dirs, files in os.walk('../data/song'):
    for d in dirs:
        if d.endswith('.s4s-song'):
            p = Path(root, d)


            # Format Konvertierung abc.s4s-song-xyz -> xyz/abc.txt
            #
            #propdir = p / 'property'
            #secdir  = p / 'section'
            #propdir.mkdir()
            #secdir.mkdir()
            # for f in p.glob('*.s4s-song-property'):
            #     r = propdir / (str(f.stem) + '.txt')
            #     print(f"{f} -> {r}")
            #     f.rename(r)
            # for f in p.glob('*.s4s-song-section'):
            #     r = secdir / (str(f.stem) + '.txt')
            #     print(f"{f} -> {r}")
            #     f.rename(r)

            
            # import/name/x.png -> attachments/import-name-x.png

            # attachmentdir = p / 'attachments'
            # if not attachmentdir.exists():
            #     attachmentdir.mkdir()
            # importdir = p / 'import'
            # if importdir.exists():
            #     for userdir in importdir.glob('*'):
            #         for importedfile in userdir.glob('*'):
            #             r = attachmentdir / ('import-' + userdir.stem + '-' + importedfile.name)
            #             print(f'{importedfile} -> {r}')
            #             importedfile.rename(r)
            #         userdir.rmdir()
            #     importdir.rmdir()

            
            # Convert Song Sheets

            # sheetdir = p / 'sheets'
            # for sheet in p.glob('*.s4s-sheet'):
            #     if not sheetdir.exists():
            #         sheetdir.mkdir()
            #     r = sheetdir / sheet.name
            #     print(f'{sheet} -> {r}')
            #     sheet.rename(r)




