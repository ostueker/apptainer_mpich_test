#!/bin/bash
#SBATCH --time=0-00:15:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=1000M

module purge
module load StdEnv/2020 intelmpi apptainer

# create $CACHE_DIR on all participating nodes
CACHE_DIR="${SLURM_TMPDIR}/.cache"
srun --ntasks-per-node=1 mkdir -p $CACHE_DIR

APPTAINER_OPTS="\
  --bind="${SLURM_TMPDIR}:/tmp,${CACHE_DIR}:/fd/.cache" \
  --home $PWD \
"

if [ -r "/opt/software/slurm/lib/libpmi2.so" ] ; then
  I_MPI_PMI_LIBRARY="/opt/software/slurm/lib/libpmi2.so"
elif [ -r "/opt/software/slurm/lib64/libpmi2.so" ] ; then
  I_MPI_PMI_LIBRARY="/opt/software/slurm/lib64/libpmi2.so"
fi
export I_MPI_PMI_LIBRARY

for CONTAINER in mpich-hybrid.sif ;
do
  for MPIRUN in mpirun mpiexec "srun --mpi=pmi2" ; do
    for TEST in /opt/mpitest /opt/mpitest_sendrecv "/opt/reduce_stddev 100000000" ; do
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
  done
done
