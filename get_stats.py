#!/usr/bin/python
import config
import datetime

B2MB = 1024*1024

stats = config.get_stats()
sec = stats.current_stats['secondsActive']
tempo = str(datetime.timedelta(seconds=sec))
down = stats.current_stats['downloadedBytes'] / B2MB
up = stats.current_stats['uploadedBytes'] / B2MB
string = tempo + " = " + str(down) + " MB down / " + str(up) + " MB up"
print string
exit()
