# Functions for performing ranking 

# mesure distance of a trajectory.
function mesure_distance {
    local cyc=$1
    local thre=$2
    
    echo 'atomnr 5391 plus atomnr 30990' | 
    gmx distance \
        -f cyc$cyc/${cyc}-${thre}.trr \
        -s cyc$cyc/${cyc}-${thre}.tpr \
        -b 0 -e $MIMD_TIME \
        -oall cyc${cyc}/dist${cyc}-${thre}.xvg 
}


# compile xvg files.
function merge_xvg {
    local cyc=$1

    for f in $(ls cyc$cyc/*.xvg);do
        grep -v "^[#@]" $f |
            sed "s/^/"${f%.xvg}"/g" >> cyc$cyc/ranking.dat

