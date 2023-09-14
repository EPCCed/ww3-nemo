#!/usr/bin/env bash

#SBATCH --partition=serial
#SBATCH --qos=serial

#SBATCH --time=00:10:00
#SBATCH --ntasks=1

set -e

# Requires: WaveWatch executable
#           input data as below

source ./build-env.sh

export MY_ROOT=$(pwd)
export WAVE_BIN="${MY_ROOT}/ww3/_build-${build_env_arch_id}/bin"

if [ ! -d INPUTS ]; then
  mkdir INPUTS
fi

cd INPUTS

if [ ! -f AMM15-coupled.tar.gz ]; then
  wget https://zenodo.org/record/7148687/files/AMM15-coupled.tar.gz
  gunzip AMM15-coupled.tar.gz
  tar -xf AMM15-coupled.tar
  gzip AMM15-coupled.tar
fi

cd AMM15-coupled

srun --cpus-per-task=1 ${WAVE_BIN}/ww3_grid

# The result should be ...
ls -l mod_def.ww3
