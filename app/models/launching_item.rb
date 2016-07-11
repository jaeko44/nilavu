require 'favour_item'

class LaunchingItem


    attr_accessor :email, :api_key, :org_id
    attr_accessor :mkp_name, :version, :cattype, :flavor
    attr_accessor :assemblyname, :componentname, :domain
    attr_accessor :keypairname, :keypairoption
    attr_accessor :region
    attr_accessor :resource, :resourceunit, :storagetype
    attr_accessor :oneclick, :options, :envs
    attr_accessor :publicipv4, :privateipv4
    attr_accessor :publicipv6, :privateipv6
    attr_accessor :type, :source , :scm_name, :scmtoken, :scmowner #historical keys, not changing them. duh ! is it ?
    attr_accessor :scmbranch, :scmtag

    ONE              = 'one'.freeze
    DOCKER           = 'docker'.freeze

    def initialize(launching_params)
        [:email, :api_key, :org_id, :mkp_name, :version, :cattype,
            :assemblyname, :domain, :keypairname, :keypairoption,
            :region, :resource, :resourceunit, :storagetype,
        :oneclick, :privateipv4, :publicipv4, :privateipv6, :publicipv6].each do |setting|
            raise Nilavu::InvalidParameters unless launching_params[setting]
            self.send("#{setting}=",launching_params[setting])
        end

        optionals(launching_params)

        ensure_unit_is_flavourized
    end

    def  componentname
        @componentname ||= /\w+/.gen.downcase
    end

    def has_docker?
        ## this has to be based on cattype.
        cattype.include? Api::Assemblies::DOCKERCONTAINER
    end

    alias name mkp_name

    # TO-DO: This can be shortened into 1 statement by  mapping as follows
    # %w(id, name, cattype, ...).map ...
    def to_h
        res =   {
            email: email,
            api_key: api_key,
            org_id: org_id,
            mkp_name: mkp_name,
            version: version,
            assemblyname: assemblyname,
            componentname: componentname,
            domain: domain,
            region: region,
            resource: resource,
            storagetype: storagetype,
            oneclick: oneclick,
            privateipv4: privateipv4,
            publicipv4: publicipv4,
            privateipv6: privateipv6,
            publicipv6: publicipv6,
            sshkey: keypairname,
            keypairoption: keypairoption,
            cattype: cattype,
            cpu: @flavor.cpu,
            ram: @flavor.ram,
            hdd: @flavor.hdd,
            options: options,
            envs: envs,
            provider: provider
        }

        set_git(res)
        res
    end


    def filtered_for_ssh
        Hash[%w(email api_key org_id keypairname keypairoption).map {|x| [x.to_sym, self.send(x.to_sym)]}]
    end

    private

    def optionals(launching_params)
        [:type, :scm_name, :source, :scmtoken, :scmbranch, :scmtag, :scmowner].each do |setting|
            self.send("#{setting}=",launching_params[setting]) if launching_params[setting]
        end
    end

    def ensure_unit_is_flavourized
        # return NOBlahError if !@resourceunit

        @flavor ||= FavourizeItem.new(@resourceunit)
    end

    def ensure_provider
        where_to ||= DOCKER
    end

    def provider
        return ONE if !has_docker?
        ensure_provider
    end

    def set_git(params)
        [:type, :source, :scm_name, :scmtoken, :scmowner,
           :scmbranch, :scmtag ].each do |repo_setting|
            params[repo_setting] = self.send("#{repo_setting}") if self.respond_to?(repo_setting)
        end
        params
    end
end
