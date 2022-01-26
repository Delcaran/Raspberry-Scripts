#!/usr/bin/python
import sys, rarfile, os
import os.path
from subprocess import check_call, call
import config


def estrai(filename, estrazione):
    try:
        check_call(["unrar", "e", filename, estrazione])
        return True
    except Exception as e:
        return False

if __name__ == '__main__':
    torrent = sys.argv[1]
    orig_dir = sys.argv[2]
    tid = sys.argv[3]
    messaggio = "DONE: " + torrent

    segmenti = orig_dir.split("/")
    extract_path = ""
    if "proratio" in segmenti:
        extract_path = orig_dir

    base_dir = orig_dir
    files = [] # archivi rar da estrarre
    file_list = config.get_torrent_files(tid)
    for file in file_list:
        filefull = os.path.join(base_dir, file)
        if os.path.isfile(filefull):
            if file.endswith(".rar") and rarfile.is_rarfile(filefull):
                if 'sample' in file:
                    pass
                else:
                    files.append(filefull)
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
    config.enqueue_email(messaggio)
    exit()

