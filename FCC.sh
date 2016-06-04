
export LCGENV_PATH=/opt/lcg
export CMTCONFIG=x86_64-ubuntu1510-gcc52-opt
export LCG_SYSTEM=x86_64-ubuntu1510-gcc52
export CMTPROJECTPATH=/home/vali/lcgcmake/cmake/toolchain

export CMAKE_PREFIX_PATH=$LCGENV_PATH/clhep/2.3.1.1/$CMTCONFIG:\
$LCGENV_PATH/HepPDT/2.06.01/$CMTCONFIG:\
$LCGENV_PATH/AIDA/3.2.1/$CMTCONFIG:\
$LCGENV_PATH/XercesC/3.1.1p1/$CMTCONFIG:\
$LCGENV_PATH/GSL/1.10/$CMTCONFIG:\
$LCGENV_PATH/RELAX/RELAX-root6/$CMTCONFIG:\
$LCGENV_PATH/libunwind/5c2cade/$CMTCONFIG:\
$LCGENV_PATH/qt5/5.4.1/$CMTCONFIG:\
$LCGENV_PATH/QMtest/2.4.1_python2.7/$CMTCONFIG:\
$LCGENV_PATH/ROOT/6.06.00/$CMTCONFIG:\
$LCGENV_PATH/Python/2.7.9.p1/$CMTCONFIG:\
$LCGENV_PATH/pytools/1.9_python2.7/$CMTCONFIG:\
$LCGENV_PATH/HepMC/2.06.09/$CMTCONFIG:\
$LCGENV_PATH/ROOT/6.06.00/$CMTCONFIG:\
$LCGENV_PATH/fastjet/3.1.1/$CMTCONFIG:\
$LCGENV_PATH/Geant4/10.02/$CMTCONFIG:\
$LCGENV_PATH/MCGenerators/pythia8/212/$CMTCONFIG:\
$HOME/FCC/Gaudi/InstallArea/$CMTCONFIG:\
$HOME/FCC/Delphes-3.3.2-install:\
$HOME/FCC/podio/install:\
$HOME/FCC/fcc-edm_install:\
$HOME/FCC/DD4hep_20152311_install
echo "set CMAKE_PREFIX_Path"
echo $CMAKE_PREFIX_PATH



echo "Set up ROOT..."
cd $LCGENV_PATH/ROOT/6.06.00/$CMTCONFIG
source bin/thisroot.sh

echo "Set up GEANT..."
cd $LCGENV_PATH/Geant4/10.02/$CMTCONFIG
source bin/geant4.sh


echo "Set Library Path..."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/FCC/fcc-edm_install/lib:$HOME/FCC/podio/install/lib:$HOME/FCC/DD4hep_20152311_install/lib:$HOME/FCC/FCCSW/build.$CMTCONFIG/lib

export PATH=$PATH:$HOME/FCC/DD4hep_20152311_install/bin


export PYTHONPATH=$PYTHONPATH:$HOME/FCC/podio/python
echo "Change to FCCSW source directory .."
cd $HOME/FCC/FCCSW

