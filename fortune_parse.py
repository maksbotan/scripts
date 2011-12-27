#!/usr/bin/env python

import re

header_re = re.compile(r'####(\w+)####\ (.+)')
footer_re = re.compile(r'\s+--\s*(.+)?\s*\((.+)\)')


fortunes_raw = open('archive.txt')


temp_list = []
fortunes = []

for line in fortunes_raw:
    if line == '%\n':
        fortunes.append(temp_list)
        temp_list = []
    else:
        temp_list.append(line)

fortunes_dicts = []

for fortune in fortunes:
    fortune_dict = {}
    fortune_text = ""
    for line in fortune:
        match = header_re.match(line)
        if match:
            fortune_dict[match.group(1)] = match.group(2)
            continue
        match = footer_re.match(line)
        if match:
            fortune_dict["author"] = match.group(1)
            fortune_dict["source"] = match.group(2)
            continue
        fortune_text += line
    fortune_dict["text"] = "\n".join(fortune_text)
    fortunes_dicts.append(fortune_dict)

print fortunes_dicts
