require 'singleton'

module Tuersteher

  class AccessRulesStorage

    include Singleton

    attr_accessor :rules_config_file # to set own access_rules-path
    attr_accessor :check_intervall # check intervall in seconds to check config file
    attr_accessor :path_prefix # prefix for path-rules

    DEFAULT_RULES_CONFIG_FILE = 'access_rules.rb' # in config-dir

    # private initializer why this class is a singleton
    def initialize
      @path_rules = []
      @model_rules = []
      @check_intervall = 300 # set default check interval to 5 minutes
    end

    def ready?
      @was_read
    end

    # get all path_rules as array of PathAccessRule-Instances
    def path_rules
      read_rules_if_needed
      @path_rules
    end

    # get all model_rules as array of ModelAccessRule-Instances
    def model_rules
      read_rules_if_needed
      @model_rules
    end


    def read_rules_if_needed
      if @was_read
        # im check_intervall pruefen ob AccessRules-File sich geändert hat
        t = Time.now.to_i
        @last_read_check ||= t
        if (t - @last_read_check) > @check_intervall
          @last_read_check = t
          cur_mtime = File.mtime(self.rules_config_file)
          @last_mtime ||= cur_mtime
          if cur_mtime > @last_mtime
            @last_mtime = cur_mtime
            read_rules
          end
        end
      else
        read_rules
      end
    end

    def rules_config_file
      @rules_config_file ||= File.join(Rails.root, 'config', DEFAULT_RULES_CONFIG_FILE)
    end

    # evaluated rules_definitions and create path-/model-rules
    def eval_rules rules_definitions
      @path_rules = []
      @model_rules = []
      eval rules_definitions, binding, (@rules_config_file||'no file')
      @was_read = true
      Tuersteher::TLogger.logger.info "Tuersteher::AccessRulesStorage: #{@path_rules.size} path-rules and #{@model_rules.size} model-rules"
      extend_path_rules_with_prefix
    end

    # Load AccesRules from file
    #  config/access_rules.rb
    def read_rules
      @was_read = false
      content = File.read self.rules_config_file
      if content
        eval_rules content
      end
    rescue => ex
      Tuersteher::TLogger.logger.error "Tuersteher::AccessRulesStorage - Error in rules: #{ex.message}\n\t"+ex.backtrace.join("\n\t")
    end

    # definiert HTTP-Pfad-basierende Zugriffsregel
    #
    # path:            :all fuer beliebig, sonst String mit der http-path beginnen muss,
    #                  wird als RegEX-Ausdruck ausgewertet
    def path url_path
      if block_given?
        @current_rule_class = AccessRule::Path
        @current_rule_init = url_path
        @current_rule_storage = @path_rules
        yield
        @current_rule_class = @current_rule_init = nil
      else
        rule = AccessRule::Path.new(url_path)
        @path_rules << rule
        rule
      end
    end

    # definiert Model-basierende Zugriffsregel
    #
    # model_class:  Model-Klassenname oder :all fuer alle
    def model model_class
      if block_given?
        @current_rule_class = AccessRule::Model
        @current_rule_init = model_class
        @current_rule_storage = @model_rules
        yield
        @current_rule_class = @current_rule_init = @current_rule_storage = nil
      else
        rule = AccessRule::Model.new(model_class)
        @model_rules << rule
        rule
      end
    end

    # create new rule as grant-rule
    # and add this to the model_rules array
    def grant
      rule = @current_rule_class.new(@current_rule_init)
      @current_rule_storage << rule
      rule.grant
    end

    # create new rule as deny-rule
    # and add this to the model_rules array
    def deny
      rule = grant
      rule.deny
    end

    # Erweitern des Path um einen Prefix
    # Ist notwenig wenn z.B. die Rails-Anwendung nicht als root-Anwendung läuft
    # also root_path != '/' ist.'
    def extend_path_rules_with_prefix
      return if @path_prefix.nil? || @path_rules.nil?
      prefix = @path_prefix.chomp('/') # das abschliessende / entfernen
      @path_rules.each do |rule|
        path_spec = rule.path_spezification
        if path_spec
          path_spec.path = "#{prefix}#{path_spec.path}"
        end
      end
      Tuersteher::TLogger.logger.info "extend_path_rules_with_prefix: #{prefix}"
    end

  end # of AccessRulesStorage

end