#!/usr/bin/python
import sys
import config

if __name__ == '__main__':
    torrent = sys.argv[1]
    messaggio = "DONE: " + torrent

    config.enqueue_email(messaggio)
    exit()

