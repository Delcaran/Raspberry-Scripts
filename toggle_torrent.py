#!/usr/bin/python
# vim: set fileencoding=utf-8 :
import sys, os
import config

file_coda = "/home/pi/.torrent/queue"
file_seed = "/home/pi/.torrent/seed"
file_check = "/home/pi/.torrent/check"
file_stop = "/home/pi/.torrent/stop"

torrents = 0

giorni_minimi = 30
secondi_minimi = giorni_minimi * 4 * 24 * 60 * 60
#secondi_minimi = giorni_minimi * 24 * 60 * 60
adesso = config.datetime.now()

def check_this_torrent(torrent):
    global secondi_minimi, adesso
    if torrent.isPrivate:
        torrent.seed_idle_mode = 'unlimited'
        torrent.seed_ratio_mode = 'unlimited'
        return False
    elif config.istntvillage(torrent.id):
        torrent.seed_idle_mode = 'single'
        torrent.seed_ratio_mode = 'single'
        torrent.seed_idle_limit = 30
        torrent.seed_ratio_limit = 10
    else:
        torrent.seed_idle_mode = 'global'
        torrent.seed_ratio_mode = 'global'
    if torrent.uploadRatio >= 1:
            return True
    else:
        done = config.datetime.fromtimestamp(torrent.doneDate)
        delta = adesso - done
        if delta.total_seconds() >= secondi_minimi:
            return True
        else:
            return False

def carica_coda(nome_file):
    print("Leggo " + nome_file, end=' ')
    queue = {}
    queue_file = open(nome_file, 'r+')
    for torrent in queue_file:
        [hash, coda] = torrent.split()
        queue[hash] = coda
    queue_file.close()
    print(" ... fatto")
    return queue

def salva_coda(nome_file, torrent_list):
    """ Scrive la coda su file """
    print("Scrivo " + nome_file, end=' ')
    queue_file = open(nome_file, 'w')
    for hash,position in torrent_list.items():
        string = str(hash) + " " + str(position) + "\n"
    queue_file.write(string)
    queue_file.close()
    print(" ... fatto")

def aggiorna_coda(ferma):
    """ Prende la coda e la lista torrent dalla sessione attiva.
    Se richiesto ferma i torrent """
    print("Avvio aggiornamento")
    global torrents, file_seed, seed_config
    seed_list = carica_coda(file_seed)
    stop_list = {}
    queue_list = {}
    check_list = {}
    if ferma:
            print("Fermo tutti i torrent")
    for torrent in torrents:
        position = torrent.queue_position
        hash = torrent.hashString
        if hash in seed_list:
            pass
        else:
            perc = torrent.percentDone
            if perc >= 1:
                should_stop = check_this_torrent(torrent)
                if torrent.isPrivate or config.istntvillage(torrent.id):
                    if should_stop:
                        check_list[hash] = position
                    else:
                        queue_list[hash] = position
                else:
                    stop_list[hash]= position
            else:
                queue_list[hash] = position
        if ferma:
            torrent.stop()
    return [stop_list, queue_list, check_list]

def applica_coda():
    global file_coda, file_check, file_stop, file_seed, torrents
    tr = len(torrents)
    print("Applico le code a " + str(tr) + " torrents")
    q_stop = carica_coda(file_stop)
    q_check = carica_coda(file_check)
    q_queue = carica_coda(file_coda)
    q_seed = carica_coda(file_seed)
    start_dict = {}
    stop_dict = {}
    stop_list = []
    start_list = []
    for torrent in torrents:
        hash = torrent.hashString
        if hash in q_queue:
            n = int(q_queue[hash])
            torrent.queue_position = n
            start_dict[n] = torrent.id
            del q_queue[hash]
        elif hash in q_seed:
            n = int(q_seed[hash])
            torrent.queue_position = n
            start_dict[n] = torrent.id
            del q_seed[hash]
        elif hash in q_stop:
            n = int(q_stop[hash])
            torrent.queue_position = n
            stop_dict[n] = torrent.id
            del q_stop[hash]
        elif hash in q_check:
            n = int(q_check[hash])
            torrent.queue_position = n
            stop_dict[n] = torrent.id
            del q_check[hash]
    #print "Avvio i torrent"
    config.avvia_tutti_torrent()
    for p in sorted(start_dict):
        start_list.append(start_dict[p])
    tostart = len(start_list)
    if tostart:
        #if len(q_queue):
            print("Avvio " + str(tostart) + " torrent")
            config.start_torrents(start_list)
    for p in sorted(stop_dict):
        stop_list.append(stop_dict[p])
    tostop = len(stop_list)
    if tostop:
        #if len(q_queue):
            print("Fermo " + str(tostop) + " torrent")
            config.stop_torrents(stop_list)
        #else:
            #print "Niente in download, lascio tutto in seed"

def ferma():
    """ Ferma tutti i torrent e salva la coda attiva """
    global file_stop, file_coda, file_check, torrents, file_seed
    print("Fermo tutto e aggiorno i file della coda")
    [stop_list, queue_list, check_list] = aggiorna_coda(True)
    salva_coda(file_stop, stop_list)
    salva_coda(file_coda, queue_list)
    salva_coda(file_check, check_list)

def salva():
    """ Salva la coda attiva """
    print("Aggiorno i file della coda")
    global file_coda, file_stop, file_check, torrents, file_seed
    [stop_list, queue_list, check_list] = aggiorna_coda(False)
    salva_coda(file_stop, stop_list)
    salva_coda(file_coda, queue_list)
    salva_coda(file_check, check_list)

if __name__ == '__main__':
    if len(sys.argv) == 2:
        transmission = config.transmission_api
        torrents = transmission.get_torrents()
        action = sys.argv[1]
        if action == "start":
            applica_coda()
        if action == "stop":
            ferma()
        if action == "salva":
            salva()
    exit()
