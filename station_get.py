#!/home/um/fw/local/bin/python
import pandas as pd
import requests
import time
import os

data_dir = r"/data/wangf/station"
stations = pd.read_csv("/home/wangf/ftp_gfs/station.txt", header=None, dtype=str)

head = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
        'Accept-Encoding': 'none',
        'Accept-Language': 'en-US,en;q=0.8',
        'Connection': 'keep-alive'}
print "task begin..."
count = 0
fail = 0
for _, s_station in stations.iterrows():
    station = s_station[0]
    url = r"http://www.nmc.cn/f/rest/passed/%s" % station
    print url

    try:
        # station_data = pd.read_json(url)
        response = resp=requests.get(url, headers=head)
        station_data = pd.read_json(response.content)
    except ValueError:
        print "station %s no data!" % station
        fail += 1
        continue
    # print station_data
    if station_data.empty:
        fail += 1
        print "station %s no data!" % station
        continue

    file_name = "%s.csv" % station
    data_path = os.path.join(data_dir, file_name)
    station_data.sort_values("time", inplace=True)
    station_data.time = pd.to_datetime(station_data.time)
    station_data.set_index("time", inplace=True)

    if os.path.exists(data_path):
        # append data
        exist_data = pd.read_csv(data_path, parse_dates=[0, ])
        latest_time = exist_data.time.iloc[-1]
        new_data = station_data[station_data.index > latest_time]
        new_data.to_csv(data_path, mode="a", float_format="%.1f",
                        header=False, date_format="%Y-%m-%d %H:%M")
    else:
        # create data
        station_data.to_csv(data_path, float_format="%.1f")

    count += 1
    time.sleep(0.52)
print "sucess: %s ;  fail: %s." % (count, fail)

