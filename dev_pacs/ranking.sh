# Functions for performing ranking 

# mesure distance of a trajectory.
function mesure_distance() {
    local cyc=$1
    local thre=$2
    
    echo 'atomnr 5391 plus atomnr 30990' | 
    gmx distance \
        -f cyc$cyc/${thre}.xtc \
        -s cyc$cyc/topol${thre}.tpr \
        -b 0 -e $MIMD_TIME \
        -oall cyc${cyc}/dist${thre}.xvg 
}


# compile xvg files.
function merge_xvg() {
    local cyc=$1

    for i in $(ls cyc$cyc/*.xvg);do
        id=$(echo $i | sed 's/cyc[0-9]\+\/dist\(.*\).xvg/\1/')
        sed -i -n 's/^[^@#]/'$id'/p' $i
    done
    cat cyc$cyc/*.xvg |
        sort -k3n,3 |
        head -n $PACS_THREADS > cyc$cyc/best_ranker.dat
}


# extract snapshot to gro format.
function generate_gro() {
    local cyc=$1

    # check if does best_ranker.dat exist?
    [ -s cyc$cyc/best_ranker.dat ] || ranking $cyc
    # get best_ranker ids.
    cyc=0
    cat cyc$cyc/best_ranker.dat |
        awk '{print "gmx trjconv -f cyc'$cyc'/" $1 ".xtc -s cyc'$cyc'/topol" $1 ".tpr -o cyc'$cyc'/" $1 "-" $2 ".gro -b " $2 " -e " $2}' |
        bash <<EOF
0
EOF
    ls cyc$cyc/*-*.gro
}



# ranking
function ranking() {
    local cyc=$1

    if [ ! -e cyc$cyc/best_ranker.dat ]; then
        # run gmx's distance
        for i in $(seq 0 $((PACS_THREADS-1)));do
            mesure_distance $cyc $i
        done
        # then, compile them
        merge_xvg $cyc
    fi
    generate_gro $cyc
}

# ranking for only pre
function pre-ranking() {
    local cyc=0

    if [ ! -s cyc$cyc/best_ranker.dat ]; then
        # run gmx's distance
        mesure_distance $cyc 0
        # then, compile them
        merge_xvg $cyc
    fi
    generate_gro $cyc
    
}
