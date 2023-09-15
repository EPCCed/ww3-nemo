# Test for Wave Watch III / NEMO coupling

## Compilation

There are four scripts at the top level: one for each of oasis3-mct, XIOS,
NEMO and WaveWatch III.

They need to be built in that order.

At the moment, oasis3-mct and XIOS will compile in a number of different
compiler configurations. However, for NEMO only `arch2-gnu-r8-d8` works
at the moment. As that is the case, WaveWatch III has only been attempted
for that choice.

See the various build scripts for details.

### Process

Update the `build-env.sh` script to set the relevant module environment
and to select `buid_env_arch_id`.

Submit the relevant scripts, e.g.,
```
$ bash ./build-oasis.sh
```

## Other data

### Generate `mod_def.ww3` file

This file is generated by running the WaveWatch executable `ww3_grid` with
appropriate input. Such input may be downloaded from:
```
https://zenodo.org/record/7148687/files/AMM15-coupled.tar.gz
```

This can be done by submitting the serial job
```
$ sbatch build-ww3-mod-def.sh
```
Note the resulting file `INPUTS/AMM15-coupled/mod_def.ww3` is a native
binary, and should be regenerated if any data sizes are changed (e.g.,
by a change in compilation options).

### Generate the wind forcing file `wind.ww3`

This is generated from appropriate input using a similar mechanism.

### Inputs from the MO

TBC

## Run time

### Run time inputs

Input files required are:
```
namcouple                oasis3-mct control file        text    link
iodef.xml                XIOS definitions                xml    info_level 100
context_nemo.xml         NEMO metadata                   xml    link
field_def_nemo-oce.xml   NEMO fields definitions (xios?) xml    link
file_def_nemo-oce.xml    NEMO output defintions  (xios?) xml    link
domain_def_nemo.xml      NEMO doamin             (nemo?) xml    link
grid_def_nemo.xml        NEMO grid               (nemo?) xml    link

namelist_cfg             NEMO parameters         (NEMO)  Fort.
namelist_ref             NEMO reference          (NEMO)  Fort.  link

amm15_..._restart.nc     NEMO initial condtion   (NEMO)  NetCDF INPUTS_MO
rmp_tor1_...-vn712.nc    oasis3-mct NEMO <-> WW3 (oasis) NetCDF link
rmp_twa1_...-vn712.nc    oasis3-mct                 ?    NetCDF link

ww3_shel.nml             WW3 configuration       (WW3)   Fort.  copy???
mod_def.ww3              WW3 grid binary info    (WW3)   native preprocessing
wind.ww3                 WW3 wind forcing        (WW3)   native preprocessing

rivers.nc                Runoff                  (NEMO)  NetCDF link
coordinates.bdy.nc       Topography data         (NEMO)  NetCDF link
coordinates.bdy_baltic.nc                                       link
```
Files labeled 'link' are from `/work/n01/shared/Q2159088/Runfiles`

With the files above `rivers.nc`, one should reach the point of a controlled
NEMO exit with
```
 STOP
 Ask for wave coupling but ln_cdgw=F, ln_sdw=F, ln_tauwoc=F, ln_stcor=F
```
in the unmodifed code (see below).

### Patch

In the NEMO source, one can manually side-step this internal check by
replacing `ctl_stop` with `ctl_warn`:
```
svn diff src/OCE/SBC/sbcblk.F90
@@ -246,7 +246,7 @@
       IF ( ln_wave ) THEN
       !Activated wave module but neither drag nor stokes drift activated
          IF ( .NOT.(ln_cdgw .OR. ln_sdw .OR. ln_tauwoc .OR. ln_stcor ) )   THEN
-            CALL ctl_stop( 'STOP',  'Ask for wave coupling but ln_cdgw=F, ln_sdw=F, ln_tauwoc=F, ln_stcor=F' )
+            CALL ctl_warn( 'KLUDGE',  'Ask for wave coupling but ln_cdgw=F, ln_sdw=F, ln_tauwoc=F, ln_stcor=F' )
```
Inspection suggests this should lead to no immediate problems.
