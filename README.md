# MPICH Hybrid Container

This is an Apptainer container with MPICH based on
https://apptainer.org/docs/user/1.2/mpi.html

The container itself should be started with `mpirun` or `srun`
so that multiple copies of the container can run on several
different nodes on an HPC cluster

## Building MPICH container from scratch (bootstrapped)

```bash
sudo apptainer build --fix-perms mpich-hybrid.sif mpich-hybrid.def

sudo apptainer build --fix-perms mpich-hybrid-slurm.sif mpich-hybrid-slurm.def
```


## Slurm Jobscript to run the test-cases inside

```bash
#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module load StdEnv/2020 intelmpi
module load apptainer
#CONTAINER="mpich-hybrid.sif"
CONTAINER="mpich-hybrid-slurm.sif"

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

MPIRUN="srun --mpi=pmi2"
if [ -r "/opt/software/slurm/lib/libpmi2.so" ] ; then
  I_MPI_PMI_LIBRARY="/opt/software/slurm/lib/libpmi2.so"
elif [ -r "/opt/software/slurm/lib64/libpmi2.so" ] ; then
  I_MPI_PMI_LIBRARY="/opt/software/slurm/lib64/libpmi2.so"
fi
export I_MPI_PMI_LIBRARY

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD "

for TEST in /opt/mpitest /opt/mpitest_sendrecv ; do
    echo "running:"
    echo "  ${MPIRUN} apptainer --silent exec \\"
    echo "    ${APPTAINER_OPTS} \\"
    echo "    ${CONTAINER} $TEST"
    echo ""
    echo "========================================="
    echo ""
    time  ${MPIRUN}  apptainer --silent exec \
            ${APPTAINER_OPTS} \
            ${CONTAINER}  $TEST
    echo ""
    echo "========================================="
    echo ""
done
```
