#!/usr/bin/env bash

set -e

# Require:
#  1. an oasis build

ROOT_DIR=$(pwd)

# Download ww3 from git

if [ ! -d ./ww3 ]; then
  git clone https://github.com/NOAA-EMC/WW3.git ww3  
  # Download, expand large binary files as per instructions
  cd ww3
  sh model/bin/ww3_from_ftp.sh
  cd ..
  # Copy the pre-processer swtiches file into position
  # This is independent of compiler/options
  cp arch/ww3/switch_archer2 ww3/model/bin
fi

module load PrgEnv-gnu
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel

arch_id="archer2-gnu-r8-d8"

# cmake requires oasis location to come from environment

export OASISDIR=${ROOT_DIR}/install/oasis3-mct/${arch_id}

cd ww3
mkdir _build-${arch_id}
cd _build-${arch_id}

cmake -DSWITCH=archer2 -DCMAKE_VERBOSE_MAKEFILE=1 \
      -DCMAKE_Fortran_FLAGS="-g -fdefault-real-8 -fdefault-double-8 -O1" \
      -DCMAKE_BUILD_TYPE=Debug ..
make -j 4

# Executables are in ...

ls -l bin/ww3_shel
