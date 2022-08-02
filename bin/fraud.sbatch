#!/bin/bash -l
#SBATCH -J rbatch
#SBATCH -o rbatch_%j.out
#SBATCH -p standard-mem-s
#SBATCH --mem=32G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8

module purge

wget https://raw.githubusercontent.com/jotsap/msds_hpc_project/main/bin/fraud_final.R

source /work/users/jotsap/spack/share/spack/setup-env.sh
spack env activate r-batch

Rscript fraud_final.R

cat /proc/cpuinfo
echo "Job ID is $SLURM_JOBID"
echo "Job Name is $SLURM_JOB_NAME"
echo "Cluster Name is $SLURM_CLUSTER_NAME"
echo "Number of nodes is $SLURM_NNODES"
echo "Memory per Node is $SLURM_MEM_PER_NODE"
echo "Memory per CPU is $SLURM_MEM_PER_CPU"
echo "Cores per Node is $SLURM_CPUS_ON_NODE"
