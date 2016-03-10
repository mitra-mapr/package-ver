#!/usr/bin/python

import sys
import os
import json
import pprint

# matrix = ['ec5-rh', 'ec5-ub']
# relDict = {'hbase': ['ec5-rh', 'ec5-ub'], 'sentry': ['ec4-ub']}
pp = pprint.PrettyPrinter(indent=4)
jsonFileName = 'example.json'


def getList(data):
    newList = []

    for e in data:
        # print e['version']
        # pp.pprint(e['os'])
        for items in e['os']:
            for item in items:
                # print items.get(item)
                if items.get(item).lower() == 'true':
                    newList.append('%s-%s' % (e['version'], item))
    return newList


def processFunc(name, data):
    print 'Copying %s to %s' % (name, data)
    return True


def main():
    compDict = {}
    with open(jsonFileName) as fh:
        jsonData = json.load(fh)

    for component in jsonData['components']:
        componentName = '%s-%s' % (component['name'], component['version'])
        if component.get('ecosystems', False):
            compDict[componentName] = getList(component['ecosystems'])
        else:
            print 'Missing ecosystem object'

    for item in compDict:
        print item
        # map(processFunc, compDict.get(item))
        [processFunc(item, x) for x in compDict.get(item)]


if __name__ == "__main__":
    main()
