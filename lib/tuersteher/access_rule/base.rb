module Tuersteher

  module AccessRule

    # Astracte base class for Access-Rules
    class Base

      attr_reader :rule_spezifications

      def initialize
        @rule_spezifications = []
        @last_role_specification
        @last_method_specification
      end

      # add role
      def role(role_name)
        return self if role_name == :all  # :all is only syntax sugar
        raise "wrong role '#{role_name}'! Must be a symbol " unless role_name.is_a?(Symbol)
        if @last_role_specification
          raise("Mixin of role and not.role are yet not implemented!") if @negation != @last_role_specification.negation
          @last_role_specification.roles << role_name
        else
          @last_role_specification = Specification::Role.new(role_name, @negation)
          @rule_spezifications << @last_role_specification
        end
        @negation = false if @negation
        self
      end

      # add list of roles
      def roles(*role_names)
        negation_state = @negation
        role_names.flatten.each do |role_name|
          role(role_name)
          @negation = negation_state # keep Negation-State for all roles
        end
        @negation = false if @negation
        self
      end

      # add extension-definition
      # parmaters:
      #   method_name:      Symbol with the name of the method to call for addional check
      #   expected_value:   optional expected value for the result of the with metho_name specified method, defalt is true
      def extension method_name, expected_value=nil
        @rule_spezifications << Specification::Extension.new(method_name, @negation, expected_value)
        @negation = false if @negation
        self
      end

      # mark this rule as grant-rule
      def grant
        self
      end

      # mark this rule as deny-rule
      def deny
        @deny = true
        self
      end

      # is this rule a deny-rule
      def deny?
        @deny
      end

      # set methode for access
      # access_method        Name of Methode for access as Symbol
      def method(access_method)
        return self if access_method==:all  # :all is only syntax sugar
        if @last_method_specification
          raise("Mixing of method and not.method are yet not implemented!") if @negation != @last_method_specification.negation
          @last_method_specification.registered_methods << access_method
        else
          @last_method_specification = Specification::Method.new(access_method, @negation)
          @rule_spezifications << @last_method_specification
        end
        @negation = false if @negation
        self
      end

      def methods(*access_methods)
        negation = @negation
        access_methods.flatten.each do |access_method|
          method(access_method)
          @negation = negation
        end
        @negation = false if @negation
        self
      end

      # negate role-membership
      def not
        @negation = true
        self
      end
      
      def to_s
        "Rule[#{@deny ? 'deny' : 'grant'}.#{@rule_spezifications.map(&:to_s).join('.')}]"
      end
      
      # check, if this rule fired for specified parameter
      def fired? path_or_model, method, login_ctx
        login_ctx = nil if login_ctx==:false # manche Authenticate-System setzen den login_ctx/user auf :false
        @rule_spezifications.all? { |spec| spec.grant?(path_or_model, method, login_ctx) }
      end

    end # of BaseAccessRule

  end

end