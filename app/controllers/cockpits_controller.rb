##
## Copyright [2013-2016] [Megam Systems]
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

class CockpitsController < ApplicationController
    include CockpitListResponder

    respond_to :html, :js

    skip_before_filter :check_xhr

    before_action :add_authkeys_for_api, only: [:index]

    def entrance
        render 'cockpits/entrance'
    end

    def index
        respond_with_list(Api::Assemblies.new.list(params).baked.flatten)
    end
end
