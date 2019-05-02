#!/bin/sh
export LD_LIBRARY_PATH=$1/lib:$LD_LIBRARY_PATH
export PATH=$1/scripts:$1/bin:$PATH:
export CPLUS_INCLUDE_DIR=$1/include:$CPLUS_INCLUDE_DIR
export PYTHONPATH=$1/python:$1/lib:$PYTHONPATH
export CMAKE_INSTALL_PREFIX=$1:$CMAKE_INSTALL_PREFIX
