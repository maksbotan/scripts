#!/usr/bin/env python
# -*- coding: utf-8; -*-

import json
import xmpp
import sys, os, getpass, signal
from datetime import datetime, date, time, timedelta

class VkSpy:
    def __init__(self, id, password):
        self.terminate = 0

        self.log_file = open('/home/maksbotan/vk_spy.debug', 'w')
        self.jid = xmpp.protocol.JID('%s@vk.com/%s' % (id, 'spy'))
        self.client = xmpp.client.Client(self.jid.getDomain(), log_file=self.log_file)
        
        try:
            self.client.connect()
        except:
            print 'Cannot connect! Aborting...'
            sys.exit(1)
        
        try:
            self.client.auth(self.jid.getNode(), password, resource=self.jid.getResource())
        except:
            print 'Cannot auth! Aborting...'

        self.roster = self.client.getRoster()

        self.client.RegisterHandler('presence', self.xmpp_presence)
        self.client.RegisterHandler('iq', self.iq)

        if os.path.exists('/home/maksbotan/log.json'):
            print 'Log exists'
            with open('/home/maksbotan/log.json', 'r') as f:
                self.log = json.load(f, encoding='utf-8')
                self.log = [ {
                    'jid': i['jid'],
                    'name': i['name'],
                    'last_enter': i['last_enter'] if self.roster.getResources(i['jid']) == None else datetime.now().strftime('%x - %X'),
                    'last_leave': i['last_leave'],
                    'online': i['online'],
                    'status': 'online' if self.roster.getResources(i['jid']) else 'offline' } for i in self.log]
                self.dump()
        else:
            self.log = [ {
                    'jid': i,
                    'name': self.roster.getName(i),
                    'last_enter': '01/01/00 - 00:00:00' if self.roster.getResources(i) == None else datetime.now().strftime('%x - %X'),
                    'last_leave': '01/01/00 - 00:00:00',
                    'online': time(0).strftime('%X'),
                    'status': 'online' if self.roster.getResources(i) else 'offline' } for i in self.roster.getItems()]
            with open('/home/maksbotan/log.json', 'w') as f:
                json.dump(self.log, f, encoding='utf-8')
        
    def iq(self, con, event):
        child  = event.getChildren()
        if len(child) == 1 and child[0].getName() == 'ping':
            print 'Sending PONG'
            res = event.buildReply('result')
            self.client.send(res)
            raise xmpp.protocol.NodeProcessed()

    def xmpp_presence(self, con, event):
#       print '%s: %s' % (self.roster.getName(event.getFrom().__str__()), event.getType())
        if event.getType() == 'unavailable':
            self.log_leave(event.getFrom())
        elif event.getType() == None:
            self.log_enter(event.getFrom())
    
    def log_leave(self, jid):
        print 'Logged leaving of %s' % self.roster.getName(str(jid)).encode('utf-8')

        for i, elem in enumerate(self.log):
            if elem['name'] == self.roster.getName(str(jid)):
                index = i
                break

        self.log[i]['status'] = 'offline'
        self.log[i]['online'] = self.calc_online(self.log[i]['online'], self.log[i]['last_enter'])
        self.dump()
    
    def calc_online(self, online, last_enter):
        time_components = [ int(j) for j in online.split('.')[0].split(':') ]
        online_delta = timedelta(hours=time_components[0], minutes=time_components[1], seconds=time_components[2])
        delta = datetime.now() - datetime.strptime(last_enter, '%x - %X') + online_delta
        return str(delta)

    def log_enter(self, jid):
        print 'Logged entering of %s' % self.roster.getName(str(jid)).encode('utf-8')
        for i, elem in enumerate(self.log):
            if elem['name'] == self.roster.getName(str(jid)):
                index = i
                break

        if self.log[i]['status'] != 'online':
            self.log[i]['status'] = 'online'
            self.log[i]['last_enter'] = datetime.now().strftime('%x - %X')
            self.dump()
    
    def close(self, num=15, frame=None):
        print 'Closing...'
        self.client.send('</stream:stream>')
        self.client.Process(1)
        self.log = [ {
                'jid': i['jid'],
                'name': i['name'],
                'last_enter': i['last_enter'],
                'last_leave': i['last_leave'] if i['status'] == 'offline' else datetime.now().strftime('%x - %X'),
                'online': self.calc_online(i['online'], i['last_enter']) if i['status'] == 'online' else i['online'],
                'status': 'offline' } for i in self.log]
        self.dump()
#        self.terminate = 1
        print 'Disconnected, exiting...'
        sys.exit(0)

    def dump(self):
        with open('/home/maksbotan/log.json', 'w') as f:
            json.dump(self.log, f, encoding='utf-8')

    def loop(self):
        try:
            while self.client.Process(1):
 #               print self.terminate
  #              if self.terminate == 1: 
   #                 sys.exit(0)
                pass
        except KeyboardInterrupt:
            self.close()

if __name__ == '__main__':
#    id = raw_input()
#    password = getpass.getpass()
    id = 'id15660980'
    password = open('/home/maksbotan/pass', 'r').read()
    open('/home/maksbotan/pass', 'w').write('')
    bot = VkSpy(id, password)
    signal.signal(signal.SIGTERM, bot.close)
    bot.loop()
