#!/usr/bin/env python3
from mpi4py import MPI
 
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank() 

print('Hello from process %d of %d'%(rank, size))

