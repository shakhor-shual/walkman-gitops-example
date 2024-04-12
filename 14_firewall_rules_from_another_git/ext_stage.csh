#!/usr/local/bin/cw4d
###########################################################################
# Copyright The Vadym Yanik.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################
# For load of any stage stored in separate git repo you should use
# script file with load process description directives ONLY
# ALL another info in this file will be IGNORED!
# any variables setup for loadable stages should be implemented
# in album-level scrits
###########################################################################
git@@@ git@github.com:shakhor-shual/walkman-gitops-example-stage.git ^main >.
