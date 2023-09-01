#!/usr/bin/env bash

set -e

# Require:
#  1. An oasis install
#  2. A set of arch files .fcm .env and .path (see arch/xios)
#
# In this script
#  1. Set the PrgEnv
#  2. Set the "arch_id" - this will select the corresponding oasis build
#
# Process
#  0. Download the svn (trunk)
#  1. Copy the relevant configuration trioka [.fcm, .env, .path] to
#     xios-2.5/arch and ensure the oasis location is set appropriately
#  2. Run the build from the top level directory

export ROOT_DIR=$(pwd)

if [ ! -d ./xios-2.5 ]; then
  svn checkout http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5
fi

module load PrgEnv-cray
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel

# copy the template arch files and sed out the dummy paths
# Set arch_id appropriately
# "archer2-gnu"        is the default precision for Gnu GCC
# "archer2-gnu-r8-d8"  adds "-fdefault-real-8 -fdefault-double-8"
# "archer2-cce"        Cray CCE default precision
# "archer2-cce-r8"     Cray CCE adds "-sreal64"

arch_id="archer2-cce-r8"

cp arch/xios/arch-${arch_id}.fcm xios-2.5/arch/arch-${arch_id}.fcm
cp arch/xios/arch-generic.path   xios-2.5/arch/arch-${arch_id}.path
cp arch/xios/arch-generic.env    xios-2.5/arch/arch-${arch_id}.env

# Update the oasis location template in the path file

sed -i 's#OASISTEMPLATE#'"${ROOT_DIR}/install/oasis3-mct/${arch_id}"'#' \
    xios-2.5/arch/arch-${arch_id}.path


cd xios-2.5

# See ./make_xios --help for details of --options
#   --debug here (--prod for production)
#   --full is to generate dependencies and recompile from scratch
#     ... there's no "make clean"

./make_xios --debug --full --use_oasis oasis3_mct --netcdf_lib netcdf4_par \
	    --arch ${arch_id} --job 8


# Copy bin, inc and lib to the install location

install=${ROOT_DIR}/install/xios/${arch_id}

printf "Copying files to %s\n" "${install}"

mkdir -p  ${install}
cp -r bin ${install}
cp -r inc ${install}
cp -r lib ${install}

module list

