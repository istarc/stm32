#!/usr/bin/python3

import itertools
from itertools import combinations
import subprocess
from subprocess import check_call, Popen, PIPE, CalledProcessError
import operator


OPT = ['O1 O2 O3 O4 O6 O7']
flags = OPT
flags += ['']  # No optimizations

# For each optimization combination measure total code size
total_size = {}
try:
    for val in flags:
        check_call(['make clean'], shell=True)  # Clean
        check_call(['make -j4 release-memopt OPT=\''+val+'\''], shell=True)  # Build using a custom optimization options
        try:
            # The following command extracts the binary size in bytes
            # 'arm-none-eabi-size bin/outp.elf | tail -n1 | awk { print $(NF-2); }
            p1 = Popen(['arm-none-eabi-size', 'bin/outp.elf'], stdout=PIPE)
            p2 = Popen(['tail', '-n1'], stdin=p1.stdout, stdout=PIPE)
            p3 = Popen(['awk', '{ print $(NF-2); }'], stdin=p2.stdout, stdout=PIPE)
            p1.stdout.close()
            total_size[val]=int(p3.communicate()[0])
        except ValueError as e:
            exit(1)
except CalledProcessError as e:
    exit(2)

# Output total size values in increasing order
#for key, val in sorted(total_size.items(), key=lambda item: item[1]):
for key, val in sorted(total_size.items(), key=lambda x: (x[1],len(x[0]))):
    if key != '':
        print('OPT '+str(val) + ' B')
    else:
        print('NON-OPT '+str(val) + ' B')

# Generate OCTAVE plot to visualize results
with open('benchmark.m', 'w+') as fh:
    y = []
    ticks = []
    # Pre-process
    for key, val in sorted(total_size.items(), key=lambda x: (x[1],len(x[0]))):
        if key != '':
            y += [val]
            ticks += ['OPT']
        else:
            y += [val]
            ticks += ['NON-OPT']

    fh.write("#!/usr/bin/octave\n"+
             "y=" + str(y) + ";\n"+
             "ticks=[" + ''.join([''.join("'"+x+"'; ") for x in ticks]) + "];\n"+
             "fh=barh(y); ylabel('Optimization'); xlabel('Code Size [B]'); title('The effect of the optimization on the binary size'); set(gca, 'ytickLabel', ticks); xt = get(gca, 'xtick'); set(gca, 'xticklabel', sprintf('%1.1E|', xt)); grid on; axis auto; saveas(fh, 'results.png', 'png');\n"+
             "saveas(fh, 'results.png', 'png');")
