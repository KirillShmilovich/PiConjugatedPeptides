#!/bin/bash

NTASKS=$(($SLURM_NTASKS_PER_NODE * $SLURM_JOB_NUM_NODES))

# SET NUMBER OF OPENMP THREADS
OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

NMOL=$1
DIMS=$2

NAME=MOL

cd 1_solvate


sed -i "s/N_MOL/$NMOL/g" topol.top
sed -i "s/MOLNAME/$NAME/g" topol.top

gmx_mpi insert-molecules -ci peptide.gro -o box.gro -nmol $NMOL -box $DIMS $DIMS $DIMS
gmx_mpi solvate -cp box.gro -cs spc216.gro -o solv.gro -p topol.top

cd ..

cp 1_solvate/solv.gro 2_em
cp 1_solvate/topol.top 2_em
cp 1_solvate/peptide.itp 2_em

cd 2_em

sed -i "s/MOLNAME/$NAME/g" npt.mdp
sed -i "s/MOLNAME/$NAME/g" nvt.mdp

gmx_mpi grompp -f minim.mdp -c solv.gro -p topol.top -o em.tpr -maxwarn 3
mpirun -np $NTASKS gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -v -deffnm em


gmx_mpi grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr -maxwarn 3

mpirun -np $NTASKS gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -v -deffnm nvt

gmx_mpi grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr -maxwarn 3

mpirun -np $NTASKS gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -v -deffnm npt


cd ..

cp 2_em/npt.gro 3_md
cp 2_em/npt.cpt 3_md
cp 2_em/topol.top 3_md
cp 2_em/peptide.itp 3_md

cd 3_md

sed -i "s/MOLNAME/$NAME/g" md.mdp

gmx_mpi grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md.tpr -maxwarn 2

mpirun -np $NTASKS gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -v -deffnm md
echo 1 | gmx_mpi trjconv -f md.xtc -o md_whole.xtc -s md.tpr -pbc whole
echo 1 | gmx_mpi trjconv -f npt.gro -o npt_whole.gro -s md.tpr -pbc whole
