#!/Users/rshimura/.pyenv/shims/python

import math
import csv
import sys
import pandas as pd

cycle, prefix, threads = sys.argv[1:]
dist_path = 'cyc' + cycle + '/' + prefix + cycle + '-' + threads
dist = pd.read_csv(dist_path+'.xvg', header=None, delim_whitespace=True,
                    index_col=0, skiprows=17)

def err(x):
    if x >= 2.6 and x <= 3.0:
        return 0
    else:
        return min(abs(x - 2.6), abs(x - 3.0))

s   = dist.apply(lambda x: x.apply(err), axis = 1) ** 2
ms  = s.mean(axis = 1)
rms = ms.apply(lambda x: math.sqrt(x))
rms_f = rms.to_frame()
rms_f.to_csv(dist_path.replace('dist', 'rmsd') + '.csv')

