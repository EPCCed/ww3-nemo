#!/usr/bin/env bash

set -e

module load PrgEnv-gnu
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel

# Set build_env_arch_id appropriately
# "archer2-gnu"        is the default precision for Gnu GCC
# "archer2-gnu-r8-d8"  adds "-fdefault-real-8 -fdefault-double-8" (*)
# "archer2-cce"        Cray CCE default precision
# "archer2-cce-r8"     Cray CCE adds "-sreal64"
# "archer2-gnu-jmmp"   Config from JMMP (*)
# (*) the only operational choices at the moment

export build_env_arch_id="archer2-gnu-jmmp"
