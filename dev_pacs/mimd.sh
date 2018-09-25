# Functions for performing MIMD


# base function for runnning grompp
function run_grompp() {
    local cyc=$1   # number of cycle
    local thre=$2  # number of thread in the cycle
    local init=$3  # initial structure .gro
    
    gmx grompp \
        -f $MDP_FILE \
        -p $GROTOP_FILE \
        -n $INDEX_FILE \
        -c $init \
        -o cyc$cyc/topol${thre}.tpr \
        -po cyc$cyc/${cyc}-${thre}.out.mdp \
        -maxwarn 1
}


# base function for runnning mdrun
function run_mdrun_multi() {
    local cyc=$1
    
    gmx mdrun \
        -s cyc$cyc/topol \
        -multi $PACS_THREADS \
        -deffnm cyc$cyc/
}


# when run grompp and mdrun for the pre-run sequentialy.
function pre_run() {
    run_grompp 0 0 $INIT_STRC
    gmx mdrun -s cyc0/topol0.tpr -deffnm cyc0/0
}


# when run grompp and mdrun of all threads sequentialy in n-th cycle.
function sequential_run() {
    local cyc=$1
    shift
    local inits=($@)
    
    # exit if (# inits != $PACS_THREADS)
    if [ ${#inits[@]} -ne $PACS_THREADS ]; then
        echo "Error in specifing inits structures"
        return 1;
    fi
    
    # run grompp for each thread
    for i in $(seq 0 $((PACS_THREADS-1)));do
        run_grompp $cyc $i ${inits[$i]}
    done
    # run mdrun
    run_mdrun_multi $cyc
}
