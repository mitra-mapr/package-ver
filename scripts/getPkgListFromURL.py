#!/usr/bin/env python

from bs4 import BeautifulSoup
import sys
import os
import urllib2
import base64
import re
import argparse

centospatt = "redhat|centos|rpm"
ubuntupatt = "ubuntu|deb|apt|trusty"


def setup():
    parser = argparse.ArgumentParser(description="Get package list from URL")
    parser.add_argument('URL', type=str)
    parser.add_argument('--user', type=str, required=False)
    parser.add_argument('--pw', type=str, required=False)
    args = parser.parse_args()
    return args


def openPage(url, username, password):
    request = urllib2.Request(url)
    if username:
        base64String = base64.standard_b64encode('%s:%s' % (username, password))
        request.add_header("Authorization", "Basic %s" % base64String)
    page = urllib2.urlopen(request)
    return page


def find_centos_rpms(args):
    url = args.URL
    page = openPage(url, args.user, args.pw)
    soup = BeautifulSoup(page, 'html.parser')
    soup.prettify()

    ecopatt = "([45]\.x)"
    ecomatch = re.search(ecopatt, url)

    ecoVersion = ''
    try:
        ecoVersion = '%s' % ecomatch.group(0)
    except:
        ecoVersion = '5.x'

    pattern = "(?P<package_name>[a-zA-Z\-]+\d?)-(?P<version>\d[\.\d\-]+\d)"
    for anchor in soup.findAll('a', href=True, string=re.compile("rpm", re.IGNORECASE)):
        # print anchor['href']
        match = re.search(pattern, anchor['href'])
        print "%s:%s:%s:%s" % (match.group('package_name'), match.group('version'), ecoVersion, "centos")


def find_ubuntu_debs(args):
    url = args.URL
    page = openPage(url, args.user, args.pw)
    soup = BeautifulSoup(page, 'html.parser')
    soup.prettify()
    data = soup.get_text().split('\n')

    blocks = soup.get_text().split('\n\n')

    ecopatt = "([45]\.x)"
    ecomatch = re.search(ecopatt, url)

    ecoVersion = ''
    try:
        ecoVersion = '%s' % ecomatch.group(0)
    except:
        ecoVersion = '5.x'

    packagepatt = "(?<=Package: ).*"
    versionpatt = "(?<=Version: ).*"
    i = 0
    verMatch = ''
    for block in blocks:
        for line in block.split('\n'):
            # print line
            packagematch = re.search(packagepatt, line)
            if packagematch:
                # print packagematch.group(0)
                for single in block.split('\n'):
                    # print single
                    if single.startswith('Version'):
                        # print single
                        versionmatch = re.search(versionpatt, single)
                        verMatch = versionmatch.group(0)
                        continue

                # versionmatch = re.search(versionpatt, data[i + 5])
                # print versionmatch.group(0)
                print "%s:%s:%s:%s" % (packagematch.group(0), verMatch, ecoVersion, "ubuntu")
            i += 1


def main(args):
    url = args.URL

    if re.search(centospatt, url):
        find_centos_rpms(args)
    elif re.search(ubuntupatt, url):
        find_ubuntu_debs(args)
    else:
        print "Unable to determine the type of URL"


if __name__ == "__main__":
    args = setup()
    main(args)
