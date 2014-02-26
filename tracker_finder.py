from BeautifulSoup import BeautifulSoup
import urllib2, sys, os, subprocess
import config

file_log = "/home/pi/.torrent/trackers_log"
script_file = "/home/pi/scripts/add_trackers.sh"

def find_trackers(torrent_hash):
    url_base = "torrentz.ph"
    url = "http://" + url_base + "/" + torrent_hash
    trackers = []
    html_page = urllib2.urlopen(url)
    soup = BeautifulSoup(html_page)
    for link in soup.findAll('a'):
        href = str(link.get('href'))
        if "tracker_" in href:
            trackers.append(link.string)
    return trackers
    #return ", ".join(trackers)

if __name__ == '__main__':
    transmission = config.transmission_api
    torrents = transmission.get_torrents()
    already_done = [line.strip() for line in open(file_log, 'r+')]
    lista_comandi = []
    da_salvare = []
    base_script = "/usr/local/bin/transmission-remote " + config.address + ":" + config.port + " -n " + config.user + ":" + config.password + " -t "
    n = len(torrents)
    c = 1
    script_f = open(script_file, 'w')
    script_f.write("#!/bin/bash\n")
    script_f.close()
    script_f = open(script_file, 'a')
    log_f = open(file_log, 'a')
    for torrent in torrents:
        print "Torrent " + str(c) + "/" + str(n) + ": ",
        if not torrent.isPrivate:
            tor_hash = torrent.hashString
            tor_id = str(torrent.id)
            script_local = base_script + tor_id + " -td "
            if tor_hash not in already_done:
                nuovi_trackers = find_trackers(tor_hash)
                print str(len(nuovi_trackers)) + " trackers"
                for tracker in nuovi_trackers:
                    script = script_local + tracker + "\n"
                    script_f.write(script)
                log_f.write(tor_hash + "\n")
            else:
                print "fatto"
        else:
            print "none"
        c = c + 1
    script_f.write("exit 0\n")
    script_f.close()
    log_f.close()

