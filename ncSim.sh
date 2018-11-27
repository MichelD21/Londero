#!/bin/sh
chmod a+rwx *.sh

export USER=~
export HDL_NAME=${1}
export CLK_FREQ=${2}
export V_PKG=$(find ~/${HDL_NAME}/trunk/frontend/ \( -iname \*.v -a -not -iname \*tb\* -a \( -iname \*pack\* -o -iname \*pkg\* \) \) )
export VHDL_PKG=$(find ~/${HDL_NAME}/trunk/frontend/ \( -iname \*.vhd -a -not -iname \*tb\* -a \( -iname \*pack\* -o -iname \*pkg\* \) \) )
UP_PATH=${USER//\//\\\/}
SDF1="SDF command file $UP_PATH\/sources\/sdf\.cmd"
SDF2="COMPILED_SDF_FILE = \"$UP_PATH\/$HDL_NAME\/trunk\/backend\/synthesis\/deliverables\/"$HDL_NAME"_"$CLK_FREQ"Mhz\.sdf\.X\"\,"
SDF3="END OF FILE: $UP_PATH\/sources\/sdf\.cmd"
CDSLIB1="define worklib $UP_PATH\/INCA_libs\/worklib"
#CDSLIB2="include \$CDS_INST_DIR\/tools\/inca\/files\/cds.lib"
CDSLIB3="define IBM $UP_PATH\/IBM"

sed -i s/SDF\ command.*cmd/"$SDF1"/ ~/sources/sdf.cmd
sed -i s/COMPILED.*\,/"$SDF2"/ ~/sources/sdf.cmd
sed -i s/END.*cmd/"$SDF3"/ ~/sources/sdf.cmd

sed -i s/define.*lib/"$CDSLIB1"/ ~/sources/cds.lib
#sed -i s/include.*lib/"$CDSLIB2"/ ~/sources/cds.lib
sed -i s/define.*IBM/"$CDSLIB3"/ ~/sources/cds.lib


nclaunch -cdslib ~/sources/cds.lib -directory ~/$HDL_NAME/trunk/frontend/ -work worklib -input ~/sources/nc.tcl
#nclaunch -new -input ~/sources/nc.tcl
