#!/usr/bin/env python3

import os
import argparse
import subprocess

POC_HOME = os.path.dirname(__file__)


def gen_parser():
    p = argparse.ArgumentParser(description='Clone concept environment')
    p.add_argument(
            '-n', "--name",
            action="store",
            default="cbpro",
            help="Name of environment.",
            metavar="ENVIRONMENT"
    )
    p.add_argument(
            '-p', '--prefix',
            action="store",
            help="Full path to environment location (i.e. prefix).",
            metavar='PATH'
    )
    p.add_argument(
            "-v", "--verbose",
            action='count',
            help="Use once for info, twice for debug, three times for trace.",
            dest="verbosity"
    )
    p.add_argument(
            "--debug",
            action="store_true",
            help='Show debug output'
    )
    
    return p


par = gen_parser()
args = par.parse_args()

env_file = 'environment.yml'
env_name = args.name

cmd_args = ""
if args.prefix:
    env_name = args.prefix
if args.verbosity:
    cmd_args += ' -' + 'v' * args.verbosity
if args.debug:
    cmd_args += ' --debug'

cmd = f"conda env create -f {env_file} -n {env_name}{cmd_args}"
print(1)
result = subprocess.run([cmd], stdout=subprocess.PIPE)
# conda
# env
# create - f - n
# ktmp
