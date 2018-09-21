# Functions for performing ranking 

# mesure distance of a trajectory.
function mesure_distance() {
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
function merge_xvg() {
    local cyc=$1

    # add threads id ot the 1st column of each xvg.
    #for f in $(ls cyc$cyc/*.xvg);do
    #    grep -v "^[#@]" $f | sed "s/^/"${f%.xvg}"/g"
    #done
    ls cyc$cyc/*.xvg | 
        sed 's/dist\(.\+\)\.xvg/\1/' |
        xargs -I@ sed -i 's/^[^#@]/'@'/g' dist@.xvg |
        sort -k2n,2 |
        head -n $PACS_THREADS |
        tee cyc$cyc/best_ranker.dat
}


# ranking
function ranking() {
    local cyc=$1

    if [ ! -e cyc$cyc/best_ranker.dat ]; then
        # run gmx's distance
        for i in $(seq 0 $((PACS_THREADS-1)));do
            mesure_distance $cyc $thre
        done
        # then, compile them
        merge_xvg $cyc
    else
        cat cyc$cyc/best_ranker.dat
    fi
}


