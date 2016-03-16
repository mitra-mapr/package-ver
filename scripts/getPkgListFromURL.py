#!/usr/bin/env python

from bs4 import BeautifulSoup
import sys
import os
import urllib2
import re
import argparse

centospatt = "redhat|centos|rpm"
ubuntupatt = "ubuntu|deb|apt"


def setup():
    parser = argparse.ArgumentParser(description="Get package list from URL")
    parser.add_argument('URL', type=str)
    args = parser.parse_args()
    return args


def find_centos_rpms(url):
    page = urllib2.urlopen(url).read()
    soup = BeautifulSoup(page, 'html.parser')
    soup.prettify()

    ecopatt = "([45]\.x)"
    ecomatch = re.search(ecopatt, url)

    pattern = "(?P<package_name>[a-zA-Z\-]+\d?)-(?P<version>\d[\.\d\-]+\d)"
    for anchor in soup.findAll('a', href=True, string=re.compile("rpm", re.IGNORECASE)):
        # print anchor['href']
        match = re.search(pattern, anchor['href'])
        print "%s:%s:%s:%s" % (match.group('package_name'), match.group('version'), ecomatch.group(0), "centos")


def find_ubuntu_debs(url):
    page = urllib2.urlopen(url).read()
    data = page.split("\n")

    ecopatt = "([45]\.x)"
    ecomatch = re.search(ecopatt, url)

    packagepatt = "(?<=Package: ).*"
    versionpatt = "(?<=Version: ).*"
    i = 0
    for line in data:
        packagematch = re.search(packagepatt, line)
        if packagematch:
            # print packagematch.group(0)
            versionmatch = re.search(versionpatt, data[i + 5])
            print "%s:%s:%s:%s" % (packagematch.group(0), versionmatch.group(0), ecomatch.group(0), "ubuntu")
        i += 1


def main(args):

    # url = sys.argv[1]
    print args.URL
    url = args.URL

    if re.search(centospatt, url):
        find_centos_rpms(url)
    elif re.search(ubuntupatt, url):
        find_ubuntu_debs(url)
    else:
        print "Unable to determine the type of URL"


if __name__ == "__main__":
    args = setup()
    main(args)
