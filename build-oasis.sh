#!/usr/bin/env bash

set -e

# Oasis coupler
#
# Require: the Makefile fragment which is the configuration for compiler
#          options etc. AKA the "arch file"
#
# Overview:
#  0. Download git
#  1. Set the relevant locations in the arch file for install etc
#  2. In directory oasis3-mct/util/make_dir edit make.inc to set the arch file
#  3. In that same directory, invoke make
#
# Everything is relative to the directory where this script resides
# $ bash ./build-archer2-gnu.sh

export ROOT_DIR=$(pwd)

if [ ! -d ./oasis3-mct ]; then
  git clone https://gitlab.com/cerfacs/oasis3-mct.git
fi

source ./build-env.sh
module list

arch_id="${build_env_arch_id}"
arch_file="${ROOT_DIR}/oasis3-mct/util/make_dir/make.${arch_id}"

cp ${ROOT_DIR}/arch/oasis3-mct/make.${arch_id} ${arch_file}

sed -i 's#COUPLETEMPLATE#'"${ROOT_DIR}/oasis3-mct"'#' ${arch_file}
sed -i 's#ARCHTEMPLATE#'"${ROOT_DIR}/install/oasis3-mct/${arch_id}"'#' ${arch_file}

# sed out the contents of the existing make.inc
# being "include " folowed by a path

make_inc=${ROOT_DIR}/oasis3-mct/util/make_dir/make.inc

sed -i 's#include .*#'"include ${arch_file}"'#' ${make_inc}

# Compile OASIS

cd ${ROOT_DIR}/oasis3-mct/util/make_dir

make realclean -f TopMakefileOasis3

make -f TopMakefileOasis3

# Make a copy of the log files

cp COMP.log make.${arch_id}.log
cp COMP.err make.${arch_id}.err

module list


# See also, e.g., a version of the user guide
# https://cerfacs.fr/wp-content/uploads/2022/03/GLOBC_TR_Valcke_oasis3mct50_2021.pdf
#
# note the last git commit was February 2023
# commit e7edb37c7a04151bc815b71689e4537b0daf00ac (HEAD -> OASIS3-MCT_5.0, origin/OASIS3-MCT_5.0,
# origin/HEAD)
