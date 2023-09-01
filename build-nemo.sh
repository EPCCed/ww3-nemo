#!/usr/bin/env bash

set -e

# Require
#   - an oasis build
#   - an xios build

# Process
# 0. Download the svn: currently v4.0.4 specifically required
#    and set up the AMM15 reference config
# 1. 

# Everything is relative to the directory in which this script resides

ROOT_DIR=$(pwd)

if [ ! -d ./nemo-r4.0.4 ]; then
  svn co http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/r4.0/r4.0.4 \
         nemo-r4.0.4
  # One time only needed
  # 1. Copy the reference preprocessor configuration fcm "AMM15" to cfgs
  # 2. Add an entry for this in the cfgs/ref_cfgs.txt file
  mkdir nemo-r4.0.4/cfgs/AMM15
  cp arch/nemo/cpp_AMM15.fcm nemo-r4.0.4/cfgs/AMM15
  cat >> nemo-r4.0.4/cfgs/ref_cfgs.txt <<EOF
AMM15 OCE
EOF
fi

module load PrgEnv-gnu
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel
module list

# copy the template arch file and sed out the dummy paths
# Set arch_id appropriately
# "archer2-gnu"        is the default precision for Gnu GCC       FAILING
# "archer2-gnu-r8-d8"  adds "-fdefault-real-8 -fdefault-double-8" WORKING
# "archer2-cce"        Cray CCE default precision                 FAILING
# "archer2-cce-r8"     Cray CCE adds "-sreal64"                   FAILING

arch_id="archer2-gnu-r8-d8"
arch_file=nemo-r4.0.4/arch/arch-${arch_id}.fcm

# Copy the architecture file and add the correct dependency locations

cp arch/nemo/arch-${arch_id}.fcm ${arch_file}
install=${ROOT_DIR}/install

sed -i 's#OASISTEMPLATE#'"${install}/oasis3-mct/${arch_id}"'#' ${arch_file}
sed -i 's#XIOSTEMPLATE#'"${install}/xios/${arch_id}"'#'        ${arch_file}

cd nemo-r4.0.4

# -r is the reference config: always "AMM15"
# -n is a name for the config to be created/used in cfgs
# -m is the arch_id (locates the arch/arch-*.fcm file)

./makenemo -n "AMM15-${arch_id}" -r AMM15 -m ${arch_id} clean
./makenemo -n "AMM15-${arch_id}" -r AMM15 -m ${arch_id} -j 4

module list

# Check we've got an executable ...

ls -l cfgs/AMM15-${arch_id}/BLD/bin/nemo.exe

# Note
# ./makenemo may produce ...
# cp: cannot stat 'AMM15/EXPREF/*namelist*': No such file or directory
# cp: cannot stat 'AMM15/EXPREF/*.xml': No such file or directory
# and various other alarming-looking statements; these may be ignored
