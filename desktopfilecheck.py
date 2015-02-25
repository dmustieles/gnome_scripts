#!/usr/bin/env python

from optparse import OptionParser

from pyg3t.gtparse import parse

p = OptionParser(usage='%prog [OPTION] [FILE...]',
                 description='check for bad desktop files in po files')

p.add_option('-v', '--verbose', action='store_true',
             help='print deskop-file-like entries whether correct or wrong')
opts, args = p.parse_args()

def check(msg):
    if not msg.istranslated:
        return
    if not msg.msgid.endswith(';'):
        return # OK, not a desktop file
    
    for comment in msg.comments:
        if '.desktop.in.in.h' in comment:
            break
    else:
        return # not a desktop file

    assert not msg.hasplurals
    
    # It's apparently a desktop file
    if not msg.msgstr.endswith(';'):
        return 'ERROR, bad syntax line %d:' % msg.meta['lineno']

    if opts.verbose:
        return 'Syntax OK line %d:' % msg.meta['lineno']
    
for fname in args:
    cat = parse(open(fname))
    for msg in cat:
        output = check(msg)
        if output:
            print fname
            print output
            print msg

