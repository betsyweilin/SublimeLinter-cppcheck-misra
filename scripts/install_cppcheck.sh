#!/usr/bin/env bash

set -e

prog_name=$(basename "${0}")
this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Usage
usage() {
    echo "Usage: ${prog_name} [ args ]"
    echo "args (optional):"
    echo "    --prefix [ install prefix ]     : default '${PREFIX}'"
    echo "    --version [ cppcheck version ]  : default '${CPPCHECK_VERSION}'"
    echo ""
    echo "This script will build and install cppcheck with misra.py addon"
    echo "from master branch of https://github.com/danmar/cppcheck."
    echo "Compiling cppcheck requires git, cmake, gcc/clang, and make."
    echo ""
    exit 1
}

# Defaults
defaults() {

    PREFIX=/usr/local
    CPPCHECK_VERSION=latest

}

# Set defaults
defaults

# Parse arguments
while [[ ${#} -ge 1 && ${1::1} == '-' ]]; do
    key="$1"
    case $key in
        '-h' | '--help' ) usage ;;
        '--prefix')
            if [[ ${#} -eq 1 ]] ; then
                usage
            else
                PREFIX="$2"
            fi
            shift
            ;;
        '--version')
            if [[ ${#} -eq 1 ]] ; then
                usage
            else
                CPPCHECK_VERSION="$2"
            fi
            shift
            ;;
        * )
            usage
            ;;
    esac
    shift
done

# Build cppcheck
echo "Installing development build of ccpcheck at prefix=${PREFIX}"
echo "------------------------------------------------------------"
echo "1. Checking out cppcheck repository to /tmp/cppcheck ..."
cd /tmp
git clone https://github.com/danmar/cppcheck
cd cppcheck
if [ "${CPPCHECK_VERSION}" != "latest" -a "${CPPCHECK_VERSION}" != "master" ] ; then
    git checkout tags/${CPPCHECK_VERSION}
fi

echo "2. Generating build files ..."
mkdir build && cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..

echo "3. Build and Install ..."
PREFIX=${PREFIX} make
sudo make install

echo "4. Copying addons and misra.py to '${PREFIX}/share/CppCheck/addons'"
sudo mkdir -p "${PREFIX}/share/CppCheck"
sudo cp -rf ../addons "${PREFIX}/share/CppCheck/"

echo "------------------------------------------------------------"
echo "Done."
