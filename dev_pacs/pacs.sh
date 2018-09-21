# vim:set foldmethod=marker:
#!/bin/bash -xv
#PBS -l nodes=16:ppn=16
#cd $PBS_O_WORKDIR
#source /home/rshimura/apps/gmx2016_3/bin/GMXRC.bash
#export OMP_NUM_THREADS=1


#################################################
# INPUT FILEs                                   #
#################################################

# Index file name include the path
INDEX_FILE="index.ndx"
# Mdp file name include the path
MDP_FILE="./runset.mdp"
# Initial structure file
INIT_STRC="../lysWaaap_lysZ_lysY/heat/md9.gro"
# Topology file 
GROTOP_FILE="../../grotop/LysYZW.top"
# Script for functions to perform MIMD (Multiple Independent MD)
MIMD_FUNC="./mimd.sh"
# Script for functions to perform Rank-process 
RANK_FUNC="./ranking.sh"


#################################################
# PaCS-MD PARAMETARS                            #
#################################################

# MIMD run time i.e. The number of snapshots to be output
MIMD_TIME='0.1'
# The number of thread
PACS_THREADS=8
# PaCS terinate condition
function isFullfill() {
    local c=$1
    if [ $c -ge 150 ]; then
        return 1
    else
        return 0
    fi
}


#################################################
# Check Parameters                              #
#################################################

# Is nsteps * dt == $MIMD_RUN ?
t=$(grep -E "nsteps|dt" $MDP_FILE | awk 'BEGIN{tmp=1} {tmp*=$3} END{print t}')
echo "t=" $t
[ $MIMD_TIME -eq $t ] ||
    echo "\$MIMD_TIME ($MIMD_TIME) != dt*nsteps (=$t) in $MDP_FILE\n";exit 1

# Is re=assign intial velcity in mdp ?
ret=$(grep "gen_vel" $MDP_FILE | grep "yes")
[ ! $ret ] || echo "You should \'gen_vel = yes\'\n"; exit 1


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
pre_run

# 1st ranking processing
best_ranker=($(ranking $cycle))

# start loop
while isFullfill $cycle; do
    $((cycle++))
    
    # dose ${best_ranker[@]} have value?
    if [ -z $best_ranker ]; then
        best_ranker=($(ranking $((cycle-1))))
    fi
    
    # grompp -> mdrun
    sequential_run $cycle $best_ranker
    # ranking
    best_ranker=($(rankinge$cycle))
done
