#!/bin/sh

source /lustre/gi58/i58005/apps/gmx2016_3/bin/GMXRC.bash
module load anaconda3

cycle=$1
threads=$2
runtime=$3
xvgprefix=$4

gmx distance -f cyc$cycle/${cycle}-${threads}.xtc \
             -s cyc$cycle/${cycle}-${threads}.tpr \
             -b 0 -e $runtime \
             -oall cyc${cycle}/${xvgprefix}${cycle}-${threads}.xvg << zzz
1
1
zzz
python ./calc_RMSD.py $cycle $xvgprefix $threads


