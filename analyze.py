#!/usr/bin/env python

from __future__ import print_function, unicode_literals

import sys, os, datetime, json

def parse_time(time):
    t = [ int(i) for i in time.split('.')[0].split(':') ]
    return datetime.timedelta(hours=t[0], minutes=t[1], seconds=t[2])

def make_log(logfile):
    log = [ [i['name'], parse_time(i['online']), i['status'] ] for i in json.load(open(logfile, 'r'), encoding='utf-8') ]
    log.sort(key=lambda l: l[1])
    log.reverse()

    return log

if __name__ == '__main__':
    if len(sys.argv) == 2:
        logfile = sys.argv[1]
    else:
        logfile = '/home/maksbotan/log.json'
    if not os.path.exists(logfile):
        print ('Logfile %s not found' % logfile)
        sys.exit(1)
  
    log = make_log(logfile)

    for i in log:
        print('{0:30}{1} {2}'.format(*[ j for j in i ]))
