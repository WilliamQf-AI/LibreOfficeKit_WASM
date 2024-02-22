#! /usr/bin/env python3
# -*- Mode: python; tab-width: 4; indent-tabs-mode: t -*-
#
# This file is part of the LibreOffice project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

import sys
import os

def main():
    optsintro = "--"
    vartofile = {}
    for arg in sys.argv[1:]:
        if not arg.startswith(optsintro):
            print("Only option args starting with -- allowed.", file=sys.stderr)
            return 1
        eqpos = arg.find("=", 2)
        if eqpos == -1:
            print("Only option args assigning with = allowed.", file=sys.stderr)
            return 2
        argname = arg[2:eqpos]
        vartofile[argname] = arg[eqpos+1:]

    print("{", end="")
    first = True
    for varandfile in vartofile.items():
        if first:
            first = False
        else:
            print(",", end="\n")
        varupper = varandfile[0].upper()
        with open(varandfile[1], "r") as filestream:
            contents = filestream.read()
        os.remove(varandfile[1])
        escapedcontents = contents.translate(str.maketrans({
            "\\": "\\\\",
            "\"": "\\\"",
            "\n": ""
        }))
        print(f"\"{varupper}\": \"{escapedcontents}\"", end="")
    print("}")
    return 0

if __name__ == "__main__":
    sys.exit(main())

# Local Variables:
# indent-tabs-mode: nil
# End:
#
# vim: set et sw=4 ts=4:
