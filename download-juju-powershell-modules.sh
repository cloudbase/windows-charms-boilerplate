#!/bin/bash

# Copyright 2014 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -e

user="cloudbase"
repo="juju-powershell-modules"
branch="master"
copy_path_juju121="hooks/Modules/"
copy_path_juju122="lib/Modules"

git clone https://github.com/$user"/"$repo".git"

pushd $repo
git checkout $branch
popd

mkdir -p $copy_path_juju121
mkdir -p $copy_path_juju122

cp -r $repo/CharmHelpers $copy_path_juju121
cp -r $repo/CharmHelpers $copy_path_juju122

rm -rf $repo
