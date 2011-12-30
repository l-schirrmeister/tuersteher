module Tuersteher

  module AccessRule

    class Model < Base
      
      # creates a new rule for model access
      #
      # clazz         Classname of the model or :all
      # access_type   Type of access (:create, :update, :destroy, :all or defined types)
      # roles         Collection of the roles for wich the rule fires (:all is also a possible value),
      #               can be given as strings or symbols
      #
      def initialize(clazz)
        raise "wrong clazz '#{clazz}'! Must be a Class or :all ." unless clazz==:all or clazz.is_a?(Class)
        @check_extensions = []
        @user_extensions = []
        super()
        if clazz != :all # :all is only syntax sugar
          @rule_spezifications << Specification::Model.new(clazz, @negation)
        end
      end

      #Overwrites the basemethod and uses Extension::Model the new option can also be the old value
      def extension method_name, options = {}
        @check_extensions << RuleExtension::Model.new(method_name, options)
        self
      end

      # add user-extension-definition
      #
      # a user extension is called on the current_user. Optional the calling model, an fixed arg or a passthrough of external args can be given
      #
      # parameters:
      #   method_name: Symbol with the name of the method to call for addional check on the current_user
      #   options:     hash of options
      # =>  :value     => specifies the result value, defaults to true
      # =>  :object    => if true, it will pass the model of the rule to the extension method, defaults to false
      # =>  :args      => an Array of args, which's elements are passed as arguments to the specified extension_method
      # =>  :pass_args => if true passes all additional args to the extension_method, defaults to false
      def user_extension method_name, options = {}
        @user_extensions << RuleExtension::User.new(method_name, options)
        self
      end

      # liefert true, wenn zugriff fuer das angegebene model mit
      # der Zugriffsart perm für das security_object hat
      #
      # model des zupruefende ModelObject
      # perm gewunschte Zugriffsart (Symbol :create, :update, :destroy)
      #
      # user ist ein User-Object (meist der Loginuser),
      # welcher die Methode 'has_role?(*roles)' besitzen muss.
      # *roles ist dabei eine Array aus Symbolen
      #
      #
      def fired? model, access_method, login_ctx, environment
        super(model, access_method, login_ctx) && grant_extension?(login_ctx, model, environment)
      end

      def to_s
        @_to_s ||= super() + " -> " + extensions.map(&:to_s).join(".")
      end

      def log_for_no_method object_name, method_name
        Tuersteher::TLogger.logger.warn("#{to_s}.fired? => false because #{object_name} hase not check-extension method '#{method_name}'!")
      end

      def log_for_wrong_number_of_arguments object_name, method_name, environment, e
        Tuersteher::TLogger.logger.warn("#{to_s}.fired? => false because '#{object_name}.#{method_name}' was called with wrong number of arguments: #{e.message}!")
      end

      private

        # checks if every user_extensions is ok if any given
        def grant_extension? user, model, environment
          return true if extensions.empty?
          extensions.all? do |extension|
            extension.grant? user, model, environment, self
          end
        end
        
        def extensions
          @check_extensions + @user_extensions
        end
        
    end

  end

end

