#!/bin/sh 
#PBS -q h-debug
#PBS -l select=2:mpiprocs=6:ompthreads=6
#PBS -W group_list=gi58
#PBS -l walltime=00:30:00

cd $PBS_O_WORKDIR
source /lustre/gi58/i58005/apps/gmx2016_3/bin/GMXRC.bash
. /etc/profile.d/modules.sh

module load intel/16.0.3.210 cuda/8.0.44

mpirun -np 24 gmx_mpi mdrun -s cyc0/topol -multi 2 -deffnm cyc1/
