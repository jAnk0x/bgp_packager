import requests
import json
import sys
def get_most_recent_version_forecast():
    '''Gets most recent release for the BGPextrap'''
    req = requests.get('https://api.github.com/repos/c-morris/BGPExtrapolator/tags')
    req_json = req.json()
    tags = {}
    for i in req_json:
        tags[i['name']] = i['commit']['sha']
    max_ver = '0.0.0'
    max_tag = ''
    for tag in tags.keys():
        if tag[0:5] != 'bgpe-':
            continue
        ver = tag[6:]
        max_ver = ver_cmp(max_ver, ver)
        if max_ver == ver:
            max_tag = tag
    return(max_tag, tags[max_tag][0:7])

def get_most_recent_version_rov():
    '''Gets the most recent release of rov++'''
    req = requests.get('https://api.github.com/repos/c-morris/BGPExtrapolator/tags')
    req_json = req.json()
    tags = {}
    for i in req_json:
        tags[i['name']] = i['commit']['sha']
    max_ver = '0.0.0'
    max_tag = ''
    for tag in tags.keys():
        if tag[0:4] != 'rov-':
            continue
        ver = tag[5:]
        max_ver = ver_cmp(max_ver, ver)
        if ver == max_ver:
            max_tag = tag
    return(max_tag, tags[max_tag][0:7])
def convert_ver(ver):
    '''Converts semantic version to just the numbers.'''
    count = ver.count('v')
    split = ver.split('v', count)
    return split[len(split)-1]
    # It just works.
##################
#Helper Functions#
##################
def ver_cmp(ver_cur, ver_new):
    '''compares two versions'''
    for i in range(3):
        if int(ver_new.split('.')[i]) > int(ver_cur.split('.')[i]):
            return ver_new
        if int(ver_new.split('.')[i]) < int(ver_cur.split('.')[i]):
            return ver_cur
# for the bash script/installer/packager
argv = sys.argv
if argv[1] == 'forecast-sha':
    print(get_most_recent_version_forecast()[1])
if argv[1] == 'rov-sha':
    print(get_most_recent_version_rov()[1])
# Holy inefficency, batman
if argv[1] == 'forecast-tag':
    print(get_most_recent_version_forecast()[0])
if argv[1] == 'rov-tag':
    print(get_most_recent_version_rov()[0])
if argv[1] == 'convert':
    print(convert_ver(argv[2]))
