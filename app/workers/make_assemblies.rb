##
## Copyright [2013-2015] [Megam Systems]
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
class MakeAssemblies
  def self.perform(options, tmp_email, tmp_api_key)
  inputs = []
  inputs << {"key" => "sshkey", "value" => options[:sshkeyname]}
  components = []
  
  if options[:instance]
    components = []
  else
    components = build_components(options, tmp_email, tmp_api_key)  
  end

    hash = {
      "name"=>"",
      "assemblies"=>[
        {
          "name"=>"#{options[:assembly_name]}",
          "components"=> components,
          "policies"=>build_policies(options),
          "inputs"=>inputs,
          "output"=>[],
          "operations"=>"",
          "status"=>"Launching",
        }
      ],
      "inputs"=>{
        "id"=>"",
        "assemblies_type"=>"",
        "label"=>"",
        "cloudsettings"=>[]
      }
    }

    hash
  end

  def self.build_components(options, email, apikey)
    com = []
    type = get_type(options[:type])
      if type == "APP"
        name = options[:appname]
        ttype = "tosca.app."
        if options[:servicename] != nil
          if options.has_key?(:related_components)
            if options[:related_components] != nil
              related_components = options[:related_components]
            end
          else
            related_components = "#{options[:assembly_name]}.#{options[:domain]}/#{options[:servicename]}"
          end
        end
      
      if type == "SERVICE"
        name = options[:servicename]
        ttype = "tosca.service."
        if options[:appname] != nil
          if options.has_key?(:related_components)
            if options[:related_components] != nil
              related_components = options[:related_components]
            end
          else
            related_components = "#{options[:assembly_name]}.#{options[:domain]}/#{options[:appname]}"
          end
        end
      end
      
      if type == "BYOC"
        name = options[:appname]
        ttype = "tosca.app."
        if options[:servicename] != nil
          if options.has_key?(:related_components)
            if options[:related_components] != nil
              related_components = options[:related_components]
            end
          else
            related_components = "#{options[:assembly_name]}.#{options[:domain]}/#{options[:servicename]}"
          end
        end
      end
      
      if type == "INSTANCE"
        ttype = "tosca.instance."
      end
    
      others = []
      enable = "false"
      scm = ""
      scm_token = ""
      scm_owner = ""
      
      if options.has_key?(:ci)
        if options[:ci]          
           enable = "true"        
        end  
        scm = "#{options[:scm_name]}"
        scm_token = "#{options[:scm_token]}"
        scm_owner = "#{options[:scm_owner]}"    
      end
      
      if type == "ADDON"
        name = options[:appname]
      end
      
      value = {
        "name"=>"#{name}",
        "tosca_type"=>"#{ttype}#{options[:type]}",
        "requirements"=> {
         ## "host"=>"#{options[:cloud]}",
          "host"=>"",
          "dummy"=>""
        },
        "inputs"=>{
          "domain"=>"#{options[:domain]}",
          "port"=>"",
          "username"=>email,
          "password"=>apikey,
          "version"=>"#{options[:version]}",
          "source"=>"#{options[:source]}",
          "design_inputs"=>{
            "id"=>"",
            "x"=>nil,
            "y"=>nil,
            "z"=>nil,
            "wires"=>[]
          },
          "service_inputs"=>{
            "dbname"=>"#{options[:dbname]}",
            "dbpassword"=>"#{options[:dbpassword]}",
          },
          "ci"=>{
             "scm"=>scm,
             "enable"=>enable,
             "token"=>scm_token,
             "owner"=>scm_owner,
            } 
        },
        "external_management_resource"=>"",
        "artifacts"=>{
          "artifact_type"=>"",
          "content"=>"",
          "artifact_requirements"=>"",
        },
        "related_components"=>"#{related_components}",
        "operations"=>{
          "operation_type"=>"",
          "target_resource"=>"",
        },
        "others"=>others,
      }
      com << value
    end
    com
  end

  def self.build_policies(options)
    com = []
    if options[:appname] != nil && options[:servicename] != nil
      value = {
        :name=>"bind policy",
        :ptype=>"colocated",
        :members=>[
          "#{options[:assembly_name]}.#{options[:domain]}/#{options[:appname]}",
          "#{options[:assembly_name]}.#{options[:domain]}/#{options[:servicename]}"
        ]
      }
    com << value
    end
    com
  end

  def self.mkp_config
    YAML.load(File.open("#{Rails.root}/config/marketplace_addons.yml", 'r'))
  end

  def self.get_type(name)
    @type = ""
    mkp_config.each do |mkp, addon|
      if mkp == name
        @type = addon["type"]
      end
    end
    @type
  end

end