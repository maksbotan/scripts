#!/usr/bin/env python

import json, argparse, os, sys, shutil, sndhdr
import string, subprocess
import os.path as osp
from copy import deepcopy
import tagpy

safechars = '!#$%&()-@^_`{}~.\' ' + string.digits + string.ascii_letters
allchars = string.maketrans('', '')
deletions = ''.join(set(allchars) - set(safechars))

def sanitize_filename(filename):
    """Remove symbols not suitable for FAT filesystems from filename"""

    return string.translate(filename, allchars, deletions)

def convert(source, destination, filename, dest_filename):
    """Use avconv to convert anything to mp3"""

    result = subprocess.call([
        'avconv', '-y', '-loglevel', 'error', '-i',
        osp.join(source, filename).encode('utf-8'),
        '-acodec', 'libmp3lame', '-ab', '256k',
        osp.join(destination, dest_filename).encode('utf-8')
    ])
    if result != 0:
        raise Exception("Failed to convert audio file")

class MusicDB():
    def __init__(self, filename=None):
        if filename:
            try:
                self.music_db = json.load(open(filename), encoding="utf-8")
            except ValueError:
                raise Exception("Cannot read json configuration file")
        else:
            self.music_db = {}

    def add_song(self, song):
        """Add song to database, creating artist dict of needed"""

        self.music_db.setdefault(song['artist'], {})[song['title']] = song

    def add_song_by_path(self, path):
        """Helper function for adding song to database. Reads tags and creates necessary object"""

        tag = tagpy.FileRef(path.strip()).tag()
        mtime = os.stat(path.strip()).st_mtime
        sane_filename = sanitize_filename(str(tag.title.encode('utf-8'))) + '.mp3'
        self.add_song({
            'artist': tag.artist,
            'title': tag.title,
            'source_filename': path.strip().decode('utf-8'),
            'mtime': mtime,
            'sane_filename': sane_filename.decode('utf-8'),
        })

    def get_song(self, song):
        """Search song in database"""

        try:
            return self.music_db[song['artist']][song['title']]
        except KeyError:
            raise KeyError("There is no such song")

    def del_song(self, song):
        """Remove song from database"""
        try:
            del self.music_db[song['artist']][song['title']]
            #If song was last of its artist, remove its dict
            if not self.music_db[song['artist']]:
                del self.music_db[song['artist']]
        except KeyError:
            pass

    def __contains__(self, song):
        """'song in db' operator support"""

        try:
            return song['title'] in self.music_db[song['artist']]
        except KeyError:
            return False

    def __iter__(self):
        """'for song in db' operator support"""
        for artist in self.music_db.values():
            for song in artist.values():
                yield song
        raise StopIteration

    def diff(self, db, incremental=True):
        """Create new database containing songs that are present in self but not in db
        If incremental, also check modification times"""

        if not isinstance(db, MusicDB):
            raise TypeError("db argument must be of MusicDB type")
        diff_db = MusicDB()
        for song in self:
            if not song in db:
                #Song is not present in db
                diff_db.add_song(song)
            elif incremental and song['mtime'] > db.get_song(song)['mtime']:
                #Song is newer than one in db
                diff_db.add_song(song)
        return diff_db

    def save(self, filename, dry=False):
        """Serialize database to json file"""

        if not dry:
            json.dump(self.music_db, open(filename, "w"), encoding="utf-8")

    def transfer(self, source, destination, current_db, dry=False):
        """Copy files in database to destination, converting them if needed and updating current_db"""

        for song in self:
            print(u"Transfering \"{} - {}\" to destination".format(song['artist'], song['title']).encode('utf-8'))
            source_path = osp.join(source, song['source_filename']).encode('utf-8')
            path = osp.join(destination, song['artist'].encode('utf-8'))
            fullpath = osp.join(path, song['sane_filename'].encode('utf-8'))
            if not dry:
                try:
                    #Create necessary directory structure
                    os.makedirs(path)
                except OSError:
                    pass

            if song['source_filename'].endswith('.mp3'):
                if not dry:
                    shutil.copyfile(source_path, fullpath)
            else:
                print("Converting...")
                if not dry:
                    convert(source, destination, song['source_filename'], fullpath)
            #Set modification time on created song
            if not dry:
                os.utime(fullpath, (song['mtime'], song['mtime']))

            current_db.add_song(song)

    def clean_up(self, destination, current_db, dry=False):
        """Remove files in database on destination"""

        for song in self:
            print("Removing \"{} - {}\" from destination".format(song['artist'], song['title']).encode('utf-8'))
            path = osp.join(destination, song['artist'].encode('utf-8'), song['sane_filename'].encode('utf-8'))
            if not dry:
                os.remove(path)
                try:
                    #Clean up empty directories
                    os.removedirs(osp.dirname(path))
                except OSError:
                    pass

            current_db.del_song(song)

def build_target_db(source, playlists, additional):
    """Crawl through source and create music database"""

    target_db = MusicDB()
    pwd = os.getcwd()
    os.chdir(source) #Hack to make os.walk return paths relative to source dir

    for playlist in (f for f in os.listdir(playlists) if f.endswith('.m3u')):
        #Load songs from mpd playlists
        songs = open(osp.join(playlists, playlist)).readlines()
        for song in songs:
            target_db.add_song_by_path(song)

    for record in (x.strip() for x in open(additional)):
        #Load songs from additional list
        if osp.isdir(record):
            for path, _, filenames in os.walk(record):
                for filename in filenames:
                    try:
                        #Test if file is audio
                        tagpy.FileRef(osp.join(path, filename))
                        target_db.add_song_by_path(osp.join(path, filename))
                    except ValueError:
                        pass
        else:
            target_db.add_song_by_path(record)

    os.chdir(pwd)
    return target_db

def main():
    parser = argparse.ArgumentParser(description="Music synchronization script")
    parser.add_argument("-s", "--source", default="/home/maksbotan/Other/Music", help="Source music directory", type=osp.abspath)
    parser.add_argument("-d", "--destination", default="/media/MaksBotan/music", help="Target music directory", type=osp.abspath)
    parser.add_argument("-p", "--playlists", default="/var/lib/mpd/playlists", help="MPD playlists directory", type=osp.abspath)
    parser.add_argument("-a", "--additional", default="/home/maksbotan/additional.list", help="Additional files", type=osp.abspath)
    parser.add_argument("-n", "--dry-run", action='store_true')

    args = parser.parse_args()

    target_db = build_target_db(args.source, args.playlists, args.additional)
    if osp.exists(osp.join(args.destination, '.music_db')):
        current_db = MusicDB(osp.join(args.destination, '.music_db'))
    else:
        current_db = MusicDB()
        current_db.save(osp.join(args.destination, '.music_db'), dry=args.dry_run)

    #Transfer new songs
    diff_db = target_db.diff(current_db)
    try:
        diff_db.transfer(args.source, args.destination, current_db, dry=args.dry_run)
    finally:
        current_db.save(osp.join(args.destination, '.music_db'), dry=args.dry_run)

    #Now delete old
    diff_db = current_db.diff(target_db, incremental=False)
    try:
        diff_db.clean_up(args.destination, current_db, dry=args.dry_run)
    finally:
        current_db.save(osp.join(args.destination, '.music_db'), dry=args.dry_run)

    print("Done :)")

if __name__ == '__main__':
    main()
