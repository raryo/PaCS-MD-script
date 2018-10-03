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

    # get best_ranker ids.
    s=($(ls cyc$cyc/*-*.gro))
    if [ -z $s ] ; then
        perl -e ' my @high_ranker=`cat cyc'$cyc'/best_ranker.dat`;print @high_ranker; foreach (@high_ranker){ my ($t, $s, @dump) = split; system "echo 0 | gmx trjconv -f cyc'$cyc'/".$t.".xtc"." -s cyc'$cyc'/topol".$t.".tpr"." -o cyc'$cyc'/".$t."-".$s.".gro"." -b ".$s." -e ".$s;}' 
    fi

}

# return ranking
function show_ranker() {
    local cyc=$1
    cat cyc$cyc/best_ranker.dat |
        awk '{ print $1"-"$2".gro" }'
}



# ranking
function ranking() {
    local cyc=$1

    if [ ! -s cyc$cyc/best_ranker.dat ]; then
        # run gmx's distance
        for i in $(seq 0 $((PACS_THREADS-1)));do
            mesure_distance $cyc $i
        done
        # then, compile them
        merge_xvg $cyc
        generate_gro $cyc
    fi
    ls cyc$cyc/*-*.gro
}

# ranking for only pre
function pre_ranking() {
    local cyc=0

    if [ ! -s cyc$cyc/best_ranker.dat ]; then
        # run gmx's distance
        mesure_distance $cyc 0
        # then, compile them
        merge_xvg $cyc
    fi
    generate_gro $cyc
    ls cyc$cyc/*-*.gro
    
}


