import config, sys, os, string

# prendo l'ID dell'ultimo DM analizzato
ultimo_id = 0
dmfile = open(config.dmfile, 'r+')
for dmid in dmfile:
    # dovrebbe essere solo uno
    ultimo_id = dmid
    break
dmfile.close()

if ultimo_id != 0:
    dms = config.get_direct_messages(ultimo_id)
else:
    exit()

nuovi_torrent = dict()

for dm in dms:
    ent = dm["entities"]
    lista = []
    for url in ent["urls"]:
        lista.append(url["expanded_url"])
    for hashtag in ent["hashtags"]:
        # dovrebbe essere uno solo per tweet
        chiave = hashtag["text"]
        if len(chiave) and len(lista):
            if chiave in nuovi_torrent:
                nuovi_torrent[chiave].extend(lista)
            else:
                nuovi_torrent[chiave] = lista
        break

if len(dms):
    # scrivo ultimo dm
    dmfile = open(config.dmfile, 'w')
    dmfile.write(str(dms[0]["id"]))
    dmfile.close()

if len(nuovi_torrent):
    for cartella, torrents in nuovi_torrent.iteritems():
        cartella = cartella.replace('_','/')
        for torrent in torrents:
            config.aggiungi_torrent_url(cartella, torrent)



