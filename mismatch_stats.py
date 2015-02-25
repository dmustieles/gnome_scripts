#!/usr/bin/env python

import re
import sys
import urllib2
from bs4 import BeautifulSoup

url_po="https://l10n.gnome.org/languages/es/%s/ui/"
url_pot="https://l10n.gnome.org/languages/C/%s/ui/"

print("Working...\n")

if len(sys.argv) < 2:
    print("Please provide the release code as script argument (e.g. gnome-3-8).")
    exit(1)

release = sys.argv[1]
page_po=urllib2.urlopen(url_po % release)
page_pot=urllib2.urlopen(url_pot % release)

def get_stats(bs_page):
    table = bs_page.find(id='stats-table')
    stats = {}
    for line in table.tbody.find_all('tr'):
        if line.find(class_='num1'):
            stats[line.find(class_='leftcell').text.strip()] = (
                int(line.find(class_='num1').string.strip() or 0),
                int(line.find(class_='num2').string.strip() or 0),
                int(line.find(class_='num3').string.strip() or 0))
    return stats

stats_for_po = get_stats(BeautifulSoup(page_po.read()))
stats_for_pot = get_stats(BeautifulSoup(page_pot.read()))

errors = False
for module, stats in stats_for_pot.items():
    if sum(stats) != sum(stats_for_po[module]):
        errors = True
        print("Count mismatch for module %s" % module)

if not errors:
    print("No count mismatch for release %s" % release)
