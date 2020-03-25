#!/bin/bash

# email on start, end, and abortion
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kirills@uchicago.edu

#SBATCH --job-name=N_MOLS_DIMS

#SBATCH --output=out.out
#SBATCH --partition=gm4-pmext
#SBATCH --account=pi-andrewferguson
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

bash sim.sh N_MOLS DIMS
