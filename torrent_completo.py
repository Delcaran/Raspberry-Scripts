#!/usr/bin/python
import sys, rarfile, os
from subprocess import check_call
import config

base_path = "/home/pi/hdd1/Serie TV/"

def estrai(path, filename, estrazione, logfile):
    filefull = os.path.join(path, filename)
    logfile.write('sono nella funzione di estrazione per '+ filefull + '\n')
    try:
        logfile.write('avvio unrar e ' + filefull + ' ' + estrazione +'\n')
        check_call(["unrar", "e", filefull, estrazione])
        logfile.write('estrazione riuscita\n')
        return True
    except Exception as e:
        logfile.write('estrazione non avvenuta\n')
        return False

def copia(path, filename, estrazione, logfile):
    if os.path.isfile(path):
        filefull = path
    else:
        filefull = os.path.join(path, filename)
    print filefull
    logfile.write('sono nella funzione di copia per '+ filefull + '\n')
    try:
        logfile.write('avvio cp ' + filefull + ' ' + estrazione +'\n')
        check_call(["cp", filefull, estrazione])
        logfile.write('copia riuscita\n')
        return True
    except Exception as e:
        logfile.write('copia non avvenuta\n')
        return False

if __name__ == '__main__':
    messaggio = ""
    logfile_name = ""
    if len(sys.argv) == 4:
        torrent = sys.argv[1]
        orig_dir = sys.argv[2]
        tid = sys.argv[3]
        logfile_name = torrent
        messaggio = "DONE: " + torrent
    elif len(sys.argv) == 6:
        risultato = sys.argv[1]
        url = sys.argv[2]
        torrent = sys.argv[3]
        orig_dir = sys.argv[4]
        tid = sys.argv[5]
        logfile_name = torrent
        messaggio = risultato + ": " + url + " " + torrent

    logfile = open('/home/pi/.torrent/scans/' + logfile_name + '.log', 'a')
    logfile.write('sono nello script di estrazione\n')

    segmenti = orig_dir.split("/")
    logfile.write('il torrent si trova nella directory ' + orig_dir + '\n')
    extract_path = ""
    if "serie" in segmenti:
        found = False
        serie_name = ""
        for s in segmenti:
            if s in config.shows_dir.keys():
                serie_name = config.shows_dir[s]
                found = True
                logfile.write('il torrent appartiene alla serie ' + serie_name + '\n')
                break
        if found:
            extract_path = base_path + serie_name + "/"
            logfile.write('estraggo nella directory ' + extract_path + '\n')
    elif "proratio" in segmenti:
        extract_path = orig_dir
        logfile.write('estraggo nella directory ' + extract_path + '\n')

    base_dir = orig_dir
    logfile.write('i file si trovano in ' + base_dir + '\n')
    files = [] # archivi rar da estrarre
    non_rar = [] # file video da copiare
    file_list = config.get_torrent_files(tid)
    for file in file_list:
        filefull = os.path.join(base_dir, file)
        if file.endswith(".rar") and rarfile.is_rarfile(filefull):
            logfile.write(filefull + ' sembra essere un rar\n')
            files.append(filefull)
        elif file.endswith(".avi") or file.endswith(".mp4") or file.endswith(".mkv"):
            if "serie" in segmenti:
                logfile.write(filefull + ' non deve essere estratto\n')
                non_rar.append(filefull)
    messaggio = ""
    if len(files) > 0:
        stat = False
        for filename in files:
            logfile.write('tento estrazione di ' + filename + '\n')
            stat = estrai(base_dir, filename, extract_path, logfile)
        if stat:
            messaggio = "EXT: " + torrent
            logfile.write('estrazione completata\n')
        else:
            messaggio = "N_EXT: " + torrent
            logfile.write('estrazione fallita\n')
    else:
        messaggio = "DONE: " + torrent
    logfile.write('messaggio twitter: ' + messaggio + '\n')
    config.tweet(messaggio)
    logfile.write('messaggio twitter inviato\n')
    if len(non_rar) > 0:
        stat = False
        for filename in non_rar:
            logfile.write('tento copia di ' + filename + '\n')
            stat = copia(base_dir, filename, extract_path, logfile)
        if stat:
            messaggio = "CP: " + torrent
            logfile.write('copia completata\n')
        else:
            messaggio = "N_CP: " + torrent
            logfile.write('copia fallita\n')
    else:
        messaggio = "DONE: " + torrent
    logfile.write('messaggio twitter: ' + messaggio + '\n')
    config.tweet(messaggio)
    logfile.write('messaggio twitter inviato\n')
    logfile.close()
    exit()

