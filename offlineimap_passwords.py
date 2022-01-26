#! /usr/bin/env python2
import os, getpass
import libkeepass

def get_keepass_pw(dbpath, title="", username=""):
    if os.path.isfile(dbpath):
        with libkeepass.open(
                os.path.expanduser(dbpath),
                password=getpass.getpass("Master password for '" + dbpath +    "': ")) as kdb:
            entry = kdb.tree.xpath(
                './/Entry'
                '/String/Key[.="Title"]/../Value[.="{title}"]/../..'
                '/String/Key[.="UserName"]/../Value[.="{username}"]/../..'
                '/String/Key[.="Password"]/../Value'.format(
                    title=title,
                    username=username
                )
            )[0]
            return entry.text
    else:
        print("Error: '" + dbpath + "' does not exist.")
        return
