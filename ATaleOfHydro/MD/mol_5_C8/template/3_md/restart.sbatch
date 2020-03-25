#!/bin/bash

# email on start, end, and abortion
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kirills@uchicago.edu

#SBATCH --job-name=NAME

#SBATCH --output=out.out
#SBATCH --partition=gm4-pmext
#SBATCH --nodes=1            # SET NUM NODES 
#SBATCH --gres=gpu:1        # SET NUM GPUS
#SBATCH --ntasks-per-node=1  # SETS NUM MPI RANKS (1 PER GPU)
#SBATCH --cpus-per-task=10    # SET NUM THREADS 
#SBATCH --qos=gm4

# THIS EXAMPLE USES 1 GPU NODE - 1 MPI TASK - 4 THREADS PER TASK

# SET NUMBER OF MPI TASKS 
# SET NUMBER OF MD STEPS

#LOAD GROMACS MODULE 


module load cuda/10.0
module load openmpi/2.0.2
source /project2/andrewferguson/Kirill/plumed_mods/plumed-2.5.2/sourceme.sh
source /project2/andrewferguson/Kirill/gromacs_2019.2/bin/GMXRC
module load Anaconda3/2019.03
source activate kirills

NTASKS=$(($SLURM_NTASKS_PER_NODE * $SLURM_JOB_NUM_NODES))

# SET NUMBER OF OPENMP THREADS
OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

mpirun -np $NTASKS gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -v -deffnm md -cpi md.cpt
echo 1 | gmx_mpi trjconv -f md.xtc -o md_whole.xtc -s md.tpr -pbc whole
echo 1 | gmx_mpi trjconv -f npt.gro -o npt_whole.gro -s md.tpr -pbc whole
