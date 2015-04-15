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

# Get the following CharmHelpers version:
CHARM_HELPERS_GIT_COMMIT="1fae7240ef29154b666fdac8c85a8fc47e90a356"

REPO_NAME="juju-powershell-modules"
REPO_URL="https://github.com/cloudbase/${REPO_NAME}.git"

CHARM_HELPERS_PATH="hooks/Modules/"
CHARM_HELPERS_FOLDER_NAME="CharmHelpers"

if [ -d "$REPO_NAME" ]; then
    rm -rf $REPO_NAME
fi
git clone $REPO_URL

pushd $REPO_NAME
git reset --hard $CHARM_HELPERS_GIT_COMMIT
popd

if [ -d "$CHARM_HELPERS_PATH/$CHARM_HELPERS_FOLDER_NAME" ]; then
    rm -rf "$CHARM_HELPERS_PATH/$CHARM_HELPERS_FOLDER_NAME"
else
    mkdir -p $CHARM_HELPERS_PATH
fi

cp -r "$REPO_NAME/$CHARM_HELPERS_FOLDER_NAME" $CHARM_HELPERS_PATH

rm -rf $REPO_NAME
