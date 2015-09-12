#!/usr/bin/python
import sys
import config

if __name__ == '__main__':
    nome = sys.argv[1]
    msg = "ADDED " + nome
    config.enqueue_email(msg)
    config.start_last_torrent()

