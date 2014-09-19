#!/usr/bin/python
import sys, rarfile, os
import os.path
from subprocess import check_call, call
import config

base_path = "/home/pi/hdd1/Serie TV/"

def estrai(filename, estrazione):
    try:
        check_call(["unrar", "e", filename, estrazione])
        return True
    except Exception as e:
        return False

def copia(path, filename, estrazione):
    if os.path.isfile(path):
        filefull = path
    else:
        filefull = os.path.join(path, filename)
    try:
        check_call(["cp", filefull, estrazione])
        return True
    except Exception as e:
        return False

if __name__ == '__main__':
    messaggio = ""
    torrent = sys.argv[1]
    orig_dir = sys.argv[2]
    tid = sys.argv[3]
    messaggio = "DONE: " + torrent

    segmenti = orig_dir.split("/")
    extract_path = ""
    if "serie" in segmenti and "completi" in segmenti and "hdd2" in segmenti:
        found = False
        serie_name = ""
        for s in segmenti:
            if s in config.shows_dir.keys():
                serie_name = config.shows_dir[s]
                found = True
                break
        if found:
            extract_path = base_path + serie_name + "/"
    elif "proratio" in segmenti:
        extract_path = orig_dir

    base_dir = orig_dir
    files = [] # archivi rar da estrarre
    non_rar = [] # file video da copiare
    file_list = config.get_torrent_files(tid)
    for file in file_list:
        filefull = os.path.join(base_dir, file)
        if os.path.isfile(filefull):
            if file.endswith(".rar") and rarfile.is_rarfile(filefull):
                if 'sample' in file:
                    pass
                else:
                    files.append(filefull)
            elif file.endswith(".avi") or file.endswith(".mp4") or file.endswith(".mkv") or file.endswith(".srt"):
                if 'sample' in file:
                    pass
                else:
                    if "serie" in segmenti:
                        non_rar.append(filefull)
    messaggio = ""
    if len(files) > 0:
        stat = False
        for filename in files:
            stat = estrai(filename, extract_path)
        if stat:
            messaggio = "EXT: " + torrent
        else:
            messaggio = "N_EXT: " + torrent
    else:
        messaggio = "DONE: " + torrent
    config.tweet(messaggio)
    if len(non_rar) > 0:
        stat = False
        for filename in non_rar:
            stat = copia(base_dir, filename, extract_path)
        if stat:
            messaggio = "CP: " + torrent
        else:
            messaggio = "N_CP: " + torrent
    else:
        messaggio = "DONE: " + torrent
    #call(["bash", "/home/pi/scripts/downloadsubs.sh", extract_path])
    config.tweet(messaggio)
    exit()

