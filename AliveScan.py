import nmap
import os, re
import config

def arpscan():
    full_results = [re.findall('^[\w\?\.]+|(?<=\s)\([\d\.]+\)|(?<=at\s)[\w\:]+', i) for i in os.popen('arp -a')]
    final_results = [dict(zip(['ip', 'lan_ip', 'mac'], i)) for i in full_results]
    return final_results

def checkWebActivity(host):
    nm = nmap.PortScanner()
    scaninfo = nm.scan(host,'22-443')
    up = scaninfo["nmap"]["scanstats"]["uphosts"]
    if up != '0':
        print "Device found"
    return up != '0'

def findHost(knownlist, alivelist):
    knownalivelist = []
    found = False
    for knownhost in knownlist:
        for alivehostinfo in list(alivelist):
            match = False
            if "mac" in alivehostinfo:
                if alivehostinfo["mac"] == knownhost["mac"]:
                    knownalivelist.append(knownhost["ip"])
                    match = True
                    found = True
            else:
                if alivehostinfo["lan_ip"].replace('(','').replace(')','') == knownhost["ip"]:
                    knownalivelist.append(knownhost["ip"])
                    match = True
                    found = True
            if match:
                alivelist.remove(alivehostinfo)
    return found, knownalivelist

def networkNeeded(check_maybe):
    return False
    alivehosts = arpscan()
    obliged, obliged_list = findHost(config.knownhosts["oblige"], alivehosts)
    maybe, maybe_list = findHost(config.knownhosts["maybe"], alivehosts)
    ignore, ignore_list = findHost(config.knownhosts["ignore"], alivehosts)
    if len(alivehosts):
        list_ufo = []
        for ufo in alivehosts:
            list_ufo.append(ufo)
        try:
            f = open(config.ufo_file, 'r')
            for line in f:
                ufo = line.strip()
                if ufo not in list_ufo:
                    list_ufo.append(ufo)
            f.close()
        except IOError:
            pass
        finally:
            f = open(config.ufo_file, 'w+')
            for ufo in list_ufo:
                pass
                #f.write(ufo + '\n')
            f.close()
    if obliged:
        print "Blocking device detected"
        return True
    if check_maybe and maybe:
        for host in maybe_list:
            return checkWebActivity(host)
    return False

if __name__ == "__main__":
    if networkNeeded(True):
        print "Serve la rete"
    else:
        print "Rete libera"
