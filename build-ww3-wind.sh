#!/usr/bin/env bash

#SBATCH --partition=serial
#SBATCH --qos=serial

#SBATCH --time=00:10:00
#SBATCH --ntasks=1

set -e

# Requires: WaveWatch executables

# Kludge .. the input file wind.nc should really be regenerated...
rm -f INPUTS/AMM15-coupled/wind.nc
ln -s /work/n01/shared/Q2159088/wind.nc INPUTS/AMM15-coupled/wind.nc

source ./build-env.sh

export MY_ROOT=$(pwd)
export WAVE_BIN="${MY_ROOT}/ww3/_build-${build_env_arch_id}/bin"

prnc_namelist="INPUTS/AMM15-coupled/ww3_prnc.nml"

cp ww3/model/nml/ww3_prnc.nml ${prnc_namelist}

# Update the TIMESTART and TIMESTOP entries
sed -i "s/20100101 120000/20170101 003000/" ${prnc_namelist}
sed -i "s/20101231 000000/20171231 003000/" ${prnc_namelist}

# Update the variable names
sed -i "s/'U'/'U10'/" ${prnc_namelist}
sed -i "s/'V'/'V10'/" ${prnc_namelist}

cd INPUTS/AMM15-coupled

srun --cpus-per-task=1 ${WAVE_BIN}/ww3_prnc

# The result should be ...
ls -l wind.ww3
