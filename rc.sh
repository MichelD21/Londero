###################################################################################
# Autorship: Leonardo L. de Oliveira, Michael G. Jordan, Michel Duarte.           #
# Last update: 11/12/2018                                                         #
###################################################################################

#!/bin/sh
chmod a+rwx *.sh

# Script Usage:
# On the home directory (~) of the current user, create a directory named "sources"
# Copy the .sdc files to ~/sources
# Create a directory in ~/sources named as the topmost file (top) in the hierarchy, excluding following .vhdl or .v
# Copy all source files of the project to the directory created in the last step
# While in the (~) of the current user, call this script using the following syntax:
# $ . rc.sh [top] [frequency] [clock] [reset]
# Where [top] is the name of top, excluding following .vhdl or .v
# [frequency] is the number in Mega Heartz of the target frequency of synthesis
# [clock] is the name of the main clock signal from the entity/module of the top
# [reset] is the name of the main reset signal from the entity/module of the top
# For further clarification, following is an example:
# $ . rc.sh somador 250 clk rst
# Will attempt to synthesize "somador.vhd", which has the main clock signal named as "clk"
# and main reset signal named as "rst", on the target frequency of 250 MHz

# Set environment variables
export USER=~
export PROJECT_DIR=~/${1}
export TECH_DIR=/home/tools/design_kits/ibm180
export HDL_NAME=${1}
export CLK_FREQ=${2}
export CLK_PERIOD=$(echo "1000/${2}" | bc -l)
export CLK_S=${3}
export RST_S=${4}

# Grab and sort verilog and vhdl files
V_PKG=$(find ~/sources/${HDL_NAME}/ \( -iname \*.v -a -not -iname \*_tb.\* -a \( -iname \*pack.\* -o -iname \*pkg.\* \) \) -exec basename {} \;)
V=$(find ~/sources/${HDL_NAME}/ \( -iname \*.v -a -not \( -iname \*_tb.\* -o -iname \*pack.\* -o -iname \*pkg.\* \) \) -exec basename {} \;)
export VERILOGS="$V_PKG $V"
VHD_PKG=$(find ~/sources/${HDL_NAME}/ \( -iname \*.vhd -a -not -iname \*_tb.\* -a \( -iname \*pack.\* -o -iname \*pkg.\* \) \) -exec basename {} \;)
VHD=$(find ~/sources/${HDL_NAME}/ \( -iname \*.vhd -a -not \( -iname \*_tb.\* -o -iname \*pack.\* -o -iname \*pkg.\* \) \) -exec basename {} \;)
export DESIGNS="$VHD_PKG $VHD"

# Print data for user checking
echo "frequency = ${CLK_FREQ} MHz"
echo "period = ${CLK_PERIOD} ns"
echo "clock signal = ${CLK_S}"
echo "reset signal = ${RST_S}"
echo ${VERILOGS}
echo ${DESIGNS}

# Create directory structure
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
mkdir -p ~/${1}/trunk/backend/synthesis/scripts
mkdir -p ~/${1}/trunk/backend/synthesis/work
mkdir -p ~/${1}/trunk/verification

# Copy logic synthesis source files
cp ~/sources/constraints.sdc ~/${1}/trunk/backend/synthesis/constraints/
cp ~/sources/path.tcl ~/${1}/trunk/backend/synthesis/scripts/
cp ~/sources/tech.tcl ~/${1}/trunk/backend/synthesis/scripts/
cp ~/sources/rc.tcl ~/${1}/trunk/backend/synthesis/scripts/
find ~/sources/${1}/ \( \( -iname \*.v -o -iname  \*.vhd \) -a -not -iname \*_tb.\* \) -exec cp {} ~/${1}/trunk/frontend/ \;

# Load modules
cd ~/${1}/trunk/backend/synthesis/work/
module add cdn/rc/rc142
module add cdn/incisiv/incisive152
module add cdn/edi/edi142

# Load Encounter RTL Compiler tcl script
rc -64 -gui -file ~/sources/rc.tcl -nolog -cmdfile rc.cmd

# Once the tool finishes, navigate back to home
cd ~