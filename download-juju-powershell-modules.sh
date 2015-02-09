#!/bin/bash
set -e

user="cloudbase"
repo="juju-powershell-modules"
branch="master"
copy_path_juju121="hooks/Modules/"
copy_path_juju122="lib/Modules"

git clone git@github.com:$user"/"$repo".git"
pushd $repo
git checkout $branch
popd

mkdir -p $copy_path_juju121
mkdir -p $copy_path_juju122

cp -r $repo/CharmHelpers $copy_path_juju121
cp -r $repo/CharmHelpers $copy_path_juju122

rm -rf $repo
