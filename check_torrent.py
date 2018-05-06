#!/usr/bin/python

import datetime
import socket
import subprocess
import os.path
from time import sleep

import transmissionrpc

from datetime import time

######## config.py Example
# eth0_ip = '192.168.1.2'
# force_start_file = "/tmp/force_start_file"
# force_stop_file = "/tmp/force_stop_file"
# pidfile =  "/tmp/pidfile"
# transpid =  "/tmp/transpid"
# 
# rpc_param = {
#         'address': '127.0.0.1',
#         'port':  '9091',
#         'user': 'user',
#         'password': 'password',
#         'socket': 12345
#         }
# week_schedule = {
#         'week': { 'start': time(0, 30), 'end': time(17, 30)},
#         'weekend': { 'start': time(2, 30), 'end': time(9)}
#         }
# commands = {
#     'vpn_start': "sudo systemctl start openvpn".split(" "),
#     'vpn_stop': "sudo systemctl stop openvpn".split(" "),
#     }
######## End Example
from config import rpc_param, week_schedule, eth0_ip, force_start_file, force_stop_file, commands, transpid, torrentdayid, hdd2_check, hdd1_check

def hdd_online():
    hdd1_online = os.path.exists(hdd1_check)
    hdd2_online = os.path.exists(hdd2_check)
    return hdd1_online and hdd2_online

def run_process_and_check(command_list, process, start):
    print "Running command " + " ".join(command_list)
    try:
        subprocess.check_call(command_list)
    except:
        print "Error running command"
        return False
        
    if start:
        print "Check if running",
        while len(subprocess.check_output(["pidof", process])) == 0:
            print "." ,
            sleep(10)
        print " OK"
        return True
    else:
        print "Check if still running",
        while True:
            try:
                print "." ,
                subprocess.check_output(["pidof", process])
                sleep(10)
            except:
                print " OK"
                return True

def time_based_check():
    """
    Time-based check if transmission should be online

    :returns: True or False
    """
    today = datetime.date.today()
    if(today.weekday() > 4):
        schedule = week_schedule['weekend']
    else:
        schedule = week_schedule['week']
    orario = datetime.datetime.time(datetime.datetime.now())
    if(orario >= schedule['start'] and orario <= schedule['end']):
        return True
    else:
        return False

def get_torrents_status():
    """
    Returns status of torrents

    :returns: Dictionary with count of torrent per status
    """
    status = {
        'all': 0,         # total number of torrents
        'done': 0,        # downloaded and seeded
        'downloading': 0, # downloading
        'seeding': 0,     # seeding
        'stopped': 0      # unknown
        }
    try:
        tc = transmissionrpc.Client(address=rpc_param['address'], port=rpc_param['port'], user=rpc_param['user'], password=rpc_param['password'])
    except:
        print "Can't connect to Transmission"
        return status
    torrents = tc.get_torrents()
    status['all'] = len(torrents)
    for torrent in torrents:
        if torrent.isFinished:
            status['done'] = status['done'] + 1
        else:
            if torrent.status == 'stopped':
                if torrent.leftUntilDone > 0:
                    status['downloading'] = status['downloading'] + 1
                else:
                    status['stopped'] = status['stopped'] + 1
            elif torrent.status == 'downloading' or torrent.status == 'download pending':
                status['downloading'] = status['downloading'] + 1
            elif torrent.status == 'seeding' or torrent.status == 'seed pending':
                status['seeding'] = status['seeding'] + 1
    return status

def torrents_based_check():
    """
    Check if transmission should be online based upon status and number of torrents

    :returns: True if transmission should be online, False otherwise
    """
    torrents_status = get_torrents_status()
    return torrents_status['downloading'] > 0

def get_local_online_ip():
    """
    Gets the IP of the interface currently connected to Internet

    :returns: A string representing the default internet IP address
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('8.8.8.8', 1))  # connect() for UDP doesn't send packets
    return s.getsockname()[0]

def start_vpn():
    """
    Starts the VPN

    :returns: IP address to use with Transmission binding
    """
    print "Starting VPN: "
    if run_process_and_check(commands['vpn_start'], "openvpn", True):
        print "VPN running"
    else:
        print "Error launching VPN"
        return "127.0.0.1"
    print "Waiting VPN connection"
    while True:
        ip = get_local_online_ip()
        if ip != eth0_ip:
            print "Now on " + ip
            return ip
        else:
            print "Still on " + ip
        sleep(10)

def stop_vpn():
    """
    Stops the VPN

    :returns: IP address to use with Transmission binding
    """
    print "Stopping VPN: " ,
    if run_process_and_check(commands['vpn_stop'], "openvpn", False):
        print "OK"
    else:
        print "Error stopping VPN"
        return "127.0.0.1"
    print "Waiting VPN shutdown"
    while True:
        ip = get_local_online_ip()
        if ip == eth0_ip:
            print "Now on " + ip
            return "127.0.0.1"
        else:
            print "Still on " + ip
        sleep(10)

def restart_vpn():
    """
    Stops the VPN

    :returns: IP address to use with Transmission binding
    """
    stop_vpn()
    return start_vpn()

def check_vpn_connection():
    """
    Checks if data is passing through VPN

    :returns: True if data is passing
    """ 
    try:
        pidof = subprocess.check_output(["pidof", "openvpn"])
    except:
        return False
    if len(pidof) == 0:
        return False
    # Testo collegamento TCP a porta DNS del server DNS di google
    try:
        host = "8.8.8.8"
        port = 53
        timeout = 3
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        print "Network available"
        return True
    except:
        print "No network available"
        return False
    return False

def manage_vpn(eth0_ip, wanted_online):
    """
    Starts or stops the VPN

    :param wanted_status: What status you want the VPN when calling this function: True or False
    :returns: IP address to use with Transmission binding
    """
    local_ip_address = get_local_online_ip()
    VPN_online = (local_ip_address != eth0_ip)
    if wanted_online:
        if VPN_online:
            if check_vpn_connection():
                print "VPN ONLINE"
            else:
                print "VPN needs restart"
                restart_vpn()
            return local_ip_address
        else:
            return start_vpn()
    else:
        if VPN_online:
            return stop_vpn()
        else:
            print "VPN OFFLINE"
            return "127.0.0.1"

def check_transmission_socket(wanted_ip):
    """
    Check if Transmission is binded to correct IP, if not restart it
    """
    print "Check if Transmission on " + str(wanted_ip)
    ss_output = subprocess.check_output(["ss","-l4tp"])
    search_string = wanted_ip+":"+str(rpc_param['socket'])
    index = ss_output.find(search_string)

    if index == -1:
        print "Transmission not correctly binded"
        print "Stopping Transmission: "
        command = "/usr/bin/transmission-remote %s:%s -n %s:%s --exit" % (rpc_param['address'], rpc_param['port'], rpc_param['user'], rpc_param['password'])
        if run_process_and_check(command.split(' '), "transmission-daemon", False):
            print "Transmission stopped"
        else:
            print "Error stopping Transmission"

        print "Starting Transmission: "
        command = "/usr/bin/transmission-daemon --bind-address-ipv4 " + wanted_ip + " -x " + transpid
        if run_process_and_check(command.split(' '), "transmission-daemon", True):
            print "Transmission launched"
        else:
            print "Error launching Transmission"

        print "Waiting Transmission RPC interface "
        Transmission_rpc_offline = True
        while Transmission_rpc_offline == True:
            ss_output = subprocess.check_output(["ss","-l4tp"])
            search_string = rpc_param['address']+":"+str(rpc_param['port'])
            Transmission_rpc_offline = ss_output.find(search_string) != -1
        print "Transmission ready"
    else:
        print "Correct Transmission binding"

def check_seed_need():
    try:
        tc = transmissionrpc.Client(address=rpc_param['address'], port=rpc_param['port'], user=rpc_param['user'], password=rpc_param['password'])
    except:
        print "Can't connect to Transmission"
        return False
    torrents = tc.get_torrents()
    to_start = []
    for torrent in torrents:
        if torrent.doneDate == 0:
            tc.start_torrent([torrent.id], bypass_queue=True)
        if torrent.uploadRatio < 1:
            difftime = datetime.date.today() - datetime.date.fromtimestamp(torrent.doneDate)
            newtorrent = difftime.days < 10
            if torrent.isPrivate and newtorrent:
                if torrent.id not in to_start: 
                    to_start.append(torrent.id)
            for tracker in torrent.trackers:
                if (torrentdayid in tracker['announce'] or torrentdayid in tracker['scrape']) and newtorrent:
                    if torrent.id not in to_start:
                        to_start.append(torrent.id)
    if len(to_start) > 0:
        print str(len(to_start)) + " torrents to be seeding"
        tc.start_torrent(to_start, bypass_queue=True)
        return True
    return False

if __name__ == "__main__":
    hdds_online = hdd_online()
    time_is_right = time_based_check()
    data_to_transfer = torrents_based_check() or check_seed_need()
    forced_stop = not hdds_online or os.path.exists(force_stop_file)
    forced_start = os.path.exists(force_start_file) and hdds_online
    local_ip_address = "127.0.0.1"

    if not hdds_online: 
        print "NO HARD DRIVES!!!"
        print "Stopping Transmission: "
        command = "/usr/bin/transmission-remote %s:%s -n %s:%s --exit" % (rpc_param['address'], rpc_param['port'], rpc_param['user'], rpc_param['password'])
        if run_process_and_check(command.split(' '), "transmission-daemon", False):
            print "Transmission stopped"
        else:
            print "Error stopping Transmission"
            commandkill = "sudo killall transmission-daemon"
            if run_process_and_check(commandkill.split(' '), "transmission-daemon", False):
                print "Transmission killed"
            else:
                print "Error killing Transmission"
    else:
        if forced_stop:
            print "Transmission should be OFFLINE"
            local_ip_address = manage_vpn(eth0_ip, False)
        elif forced_start:
            print "Transmission should be ONLINE"
            local_ip_address = manage_vpn(eth0_ip, True)
        elif not hdd_online or not time_is_right or not data_to_transfer:
            print "Transmission should be OFFLINE"
            local_ip_address = manage_vpn(eth0_ip, False)
        elif (hdds_online and time_is_right and data_to_transfer):
            print "Transmission should be ONLINE"
            local_ip_address = manage_vpn(eth0_ip, True)

        check_transmission_socket(local_ip_address)

