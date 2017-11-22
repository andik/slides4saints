import os
from pathlib import Path

from itertools import chain

for root, dirs, files in os.walk('../data/song'):
    for p in chain(dirs, files):
        p = Path(root, p)

        if ' ' in str(p):
            r = str(p).replace(' ', '-')
            print(f'found space in file {p} -> {r}')
            p.rename(r)

