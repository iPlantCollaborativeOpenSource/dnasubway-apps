#!/usr/bin/env python

import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("job")

args = parser.parse_args()


def formatForTester(variable, value):
    formatted = 'export ' + str(variable) + '=\"' + str(value) + '\"\n'
    return formatted


with open(args.job) as f:
    s = f.read()

tester = open('tester.txt', 'w')

jsonDoc = json.loads(s)
stanzas = ['inputs', 'parameters']
for s in stanzas:
    comment = ('# ' + s + '\n')
    tester.write(comment)
    if s in jsonDoc:
        for x in jsonDoc[s].keys():
            k = str(x)
            v = jsonDoc[s][k]
            if isinstance(v, bool):
                print k + ' is bool type'
                if v is True:
                    v = "1"
                else:
                    v = "0"
            wrap_line = formatForTester(k, v)
            tester.write(wrap_line)
