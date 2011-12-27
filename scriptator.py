#!/usr/bin/env python

import os, subprocess, threading, sys

file_counter = 0
file_counter_lock = threading.Lock()

files = [i for i in os.listdir(os.getcwd()) if i.endswith('.flac')]
files_number = len(files)

if len(sys.argv) == 2:
    script = sys.argv[1]
    threads = 2
elif len(sys.argv) == 4 and sys.argv[2] == '-n':
    script = sys.argv[1]
    threads = int(sys.argv[3])
else:
    print "Usage: %s script [-n threads]" % sys.argv[0]
    sys.exit(1)

threads_semaphore = threading.Semaphore(threads)

def worker():
    global file_counter

    file_counter_lock.acquire()
    try:
        file = files[file_counter]
        file_counter = file_counter + 1
    except IndexError:
        return
    finally:
        file_counter_lock.release()

    print "[+] Processing file %s (%s/%s)" % (file, file_counter, files_number)

    log = open("%s.log" % file, "w")

    retcode = subprocess.call('%s "%s"' % (script, file), shell=True, stdout=log, stderr=subprocess.STDOUT)
    if retcode == 0:
        print "[+] Success processing file %s" % file
    else:
        print "[+] Error processing file %s" % file

    log.close()

    threads_semaphore.release()

while file_counter <= files_number-1:
    threads_semaphore.acquire()
    threading.Thread(target=worker).start()
