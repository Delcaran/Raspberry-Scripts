#!/usr/bin/python
import sys
import config

if __name__ == '__main__':
    nome = sys.argv[1]
    tweet = "ADDED " + nome
    config.tweet(tweet)
    config.start_last_torrent()

