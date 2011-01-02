#!/usr/bin/env python

import sys, os, datetime, json

if len(sys.argv) == 2:
    logfile = sys.argv[1]
else:
    logfile = '/home/maksotan/log.json'

if not os.path.exists(logfile):
    print 'Logfile %s not found' % logfile
    sys.exit(1)
    
def parse_time(time):
    t = [ int(i) for i in time.split('.')[0].split(':') ]
    return datetime.timedelta(hours=t[0], minutes=t[1], seconds=t[2])

log = [ [unicode(i['name']), parse_time(i['online']), i['status'] ] for i in json.load(open(logfile, 'r')) ]
log.sort(key=lambda l: l[1])
log.reverse()

for i in log:
    print "%s\t%s\t%s" % tuple([ unicode(j).encode('utf-8') for j in i ])
