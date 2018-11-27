#!/bin/sh
chmod a+rwx *.sh

export USER=~
export PROJECT_DIR=~/${1}
export TECH_DIR=/home/tools/design_kits/ibm180
export HDL_NAME=${1}
export CLK_FREQ=${2}
export CLK_PERIOD=$(echo "1000/${2}" | bc -l)
export CLK_S=${3}
export RST_S=${4}
echo "frequency = ${CLK_FREQ} MHz"
echo "period = ${CLK_PERIOD} ns"
echo "clock signal = ${CLK_S}"
echo "reset signal = ${RST_S}"

# Grab and sort verilog and vhdl files
V_PKG=$(find ~/sources/${HDL_NAME}/ \( -iname \*.v -a -not -iname \*tb\* -a \( -iname \*pack\* -o -iname \*pkg\* \) \) -exec basename {} \;)
V=$(find ~/sources/${HDL_NAME}/ \( -iname \*.v -a -not \( -iname \*tb\* -o -iname \*pack\* -o -iname \*pkg\* \) \) -exec basename {} \;)
export VERILOGS="$V_PKG $V"
echo ${VERILOGS}
VHD_PKG=$(find ~/sources/${HDL_NAME}/ \( -iname \*.vhd -a -not -iname \*tb\* -a \( -iname \*pack\* -o -iname \*pkg\* \) \) -exec basename {} \;)
VHD=$(find ~/sources/${HDL_NAME}/ \( -iname \*.vhd -a -not \( -iname \*tb\* -o -iname \*pack\* -o -iname \*pkg\* \) \) -exec basename {} \;)
export DESIGNS="$VHD_PKG $VHD"
echo ${DESIGNS}

mkdir -p ~/${1}/trunk/frontend/hdl_temp
mkdir -p ~/${1}/trunk/frontend/simulation
mkdir -p ~/${1}/trunk/backend/layout/constraints
mkdir -p ~/${1}/trunk/backend/layout/deliverables
mkdir -p ~/${1}/trunk/backend/layout/outputs
mkdir -p ~/${1}/trunk/backend/layout/reports
mkdir -p ~/${1}/trunk/backend/layout/scripts
mkdir -p ~/${1}/trunk/backend/layout/work
mkdir -p ~/${1}/trunk/backend/synthesis/constraints
mkdir -p ~/${1}/trunk/backend/synthesis/deliverables
mkdir -p ~/${1}/trunk/backend/synthesis/reports
mkdir -p ~/${1}/trunk/backend/synthesis/scripts/common
mkdir -p ~/${1}/trunk/backend/synthesis/work
mkdir -p ~/${1}/trunk/verification

cp ~/sources/path.tcl ~/${1}/trunk/backend/synthesis/scripts/common/
cp ~/sources/tech.tcl ~/${1}/trunk/backend/synthesis/scripts/common/

cp ~/sources/constraints.sdc ~/${1}/trunk/backend/synthesis/constraints/
find ~/sources/${1}/ -maxdepth 2 -iname \*.v -exec cp {} ~/${1}/trunk/frontend/ \;
find ~/sources/${1}/ -maxdepth 2 -iname \*.vhd -exec cp {} ~/${1}/trunk/frontend/ \;

cd ~/${1}/trunk/backend/synthesis/work/

module add cdn/rc/rc142
module add cdn/incisiv/incisive152

rc -64 -gui -file ~/sources/rc.tcl -logfile rc.log -cmdfile rc.cmd

cd ~
