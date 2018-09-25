#!/bin/bash

case $1 in 
    grompp   ) python modules/grompp.py;;
    mdrun    ) python modules/mdrun.py;;
    distance ) python modules/distance.py;;
esac

