#!/bin/sh

source /lustre/gi58/i58005/apps/gmx2016_3/bin/GMXRC.bash

gro_file=$1
top_file=$2
cycle=$3
threads=$4

gmx grompp \
    -f runset.mdp \
    -c $gro_file \
    -p $top_file \
    -o cyc${cycle}/${cycle}-${threads}.tpr \
    -po cyc${cycle}/${cycle}-${threads}.out.mdp \
   -maxwarn 1
