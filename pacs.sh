#!/bin/sh 
#PBS -q h-debug
#PBS -l select=4:mpiprocs=6:ompthreads=6
#PBS -W group_list=gi58
#PBS -l walltime=00:30:00

cd $PBS_O_WORKDIR
source /lustre/gi58/i58005/apps/gmx2016_3/bin/GMXRC.bash
. /etc/profile.d/modules.sh

module load intel/16.0.3.210 cuda/8.0.44


#################################################
# INPUT FILEs                                   #
#################################################

# Index file name include the path
INDEX_FILE="./index.ndx"
# Mdp file name include the path
MDP_FILE="./runset.mdp"
# Initial structure file
INIT_STRC="./md9.gro"
# Topology file 
GROTOP_FILE="./grotop/LysYZW.top"
# Script for functions to perform MIMD (Multiple Independent MD)
MIMD_FUNC="./mimd.sh"
# Script for functions to perform Rank-process 
RANK_FUNC="./ranking.sh"


#################################################
# PaCS-MD PARAMETARS                            #
#################################################

# MIMD run time [ps], i.e. The number of snapshots to be output
MIMD_TIME='50'
# The number of thread
PACS_THREADS=4
# PaCS terinate condition
function isFullfill() {
    local c=$1
    if [ $c -ge 5 ]; then
        return 1
    else
        return 0
    fi
}


#################################################
# Check Parameters                              #
#################################################

# Is nsteps * dt == $MIMD_RUN ?
t=$(grep -E "nsteps|dt" $MDP_FILE |
    awk 'BEGIN{tmp=1} {tmp*=$3} END{print tmp}')
[ $MIMD_TIME = $t ] ||
    { echo "\$MIMD_TIME (=$MIMD_TIME) != dt*nsteps (=$t) in $MDP_FILE\n"; exit 1; }

# Is re-assign intial velcity in mdp ?
ret=$(grep "gen_vel" $MDP_FILE | grep "yes")
[ -n "$ret" ] || 
    { echo "You should \'gen_vel = yes\'\n"; exit 1; }


#################################################
# Load functions defined external files         #
#################################################

for f in $MIMD_FUNC $RANK_FUNC; do
    if [ -e $f ]; then
        source $f
    else
        echo "Cannot load $f.\n"; exit 1
    fi
done


#################################################
# MAIN                                          #
#   Iterate MIMD and Ranking until fullfill the #
#   requirement, e.g., RMSD < 3 [ang]           #
#################################################

# cycle counter
cycle=0

# start pre-short-run
if [ ! -d cyc${cycle} ];then
    mkdir cyc${cycle}
fi
pre_run

# 1st ranking processing
pre_ranking
best_ranker=($(show_ranker $cycle))

# start loop
while isFullfill $cycle; do
    cycle=$((cycle+1))
    
    # dose ${best_ranker[@]} have value?
    if [ -z "$best_ranker" ]; then
        best_ranker=($(show_ranker $((cycle-1))))
    fi
    echo "@cycle$cycle: best_ranker=${best_ranker[@]} <- $cycle-1"
    
    # grompp -> mdrun
    [ -d cyc${cycle} ] || mkdir cyc${cycle}
    sequential_run $cycle ${best_ranker[@]} || exit 1
    # ranking
    ranking $cycle
    best_ranker=($(show_ranker $cycle))
done
