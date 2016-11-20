#!/usr/bin/env python

from __future__ import print_function
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("app")

args = parser.parse_args()


def formatForRunner(variable):
    formatted = variable.upper() + '=${' + variable + '}'
    return formatted


def formatForWrapper(assignment):
    line = 'echo "' + assignment + '" >> ${DOCK_ENV}'
    return line


with open(args.app) as f:
    s = f.read()

runner = open('runner.txt', 'w')
wrapper = open('wrapper.txt', 'w')

jsonDoc = json.loads(s)
stanzas = ['inputs', 'parameters', 'outputs']
for s in stanzas:
    comment = ('# ' + s + '\n')
    runner.write(comment)
    wrapper.write(comment)
    if s in jsonDoc:
        for x in jsonDoc[s]:
            run_line = formatForRunner(x['id'])
            wrap_line = formatForWrapper(run_line)
            runner.write(run_line + '\n')
            wrapper.write(wrap_line + '\n')
