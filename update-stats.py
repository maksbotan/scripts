#!/usr/bin/env python
# -*- coding: utf8; -*-

import os, re, json
import jinja2
import analyze
#Get main templates
template = jinja2.Template(open('stats.jhtml', 'r').read().decode('utf-8'))

log_regex = re.compile(r'log.json-(\d{4}-\d{2}-\d{2})') #Regex for finding valid logs

basedir = os.environ.get('HOME', '/home/maksbotan') #Dir with logs
#Get all log files
logfiles = [f for f in os.listdir(basedir) if log_regex.match(f)]

logs = []
for logfile in logfiles:
    with open(os.path.join(basedir, logfile), 'r') as f:
        #Store ligfile in list along with it's date
        log = analyze.make_log(os.path.join(basedir, logfile))
        for i in xrange(len(log)):
            log[i][1] = str(log[i][1])  #Make human-readable view of time
        logs.append({'log': log, 'date': log_regex.match(logfile).group(1)})

with open('stats.html', 'w') as f:
    #Render page
    f.write(template.render(logs=logs).encode('utf-8'))
