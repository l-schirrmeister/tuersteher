module Tuersteher
  
  # Module for include in Model-Object-Classes
    #
    # The module get the current-user from Thread.current[:user]
    #
    # Sample for ActiveRecord-Class
    #   class Sample < ActiveRecord::Base
    #    include Tuersteher::ModelExtensions
    #
    #     def transfer_to account
    #       check_model_access :transfer # raise a exception if not allowed
    #       ....
    #     end
    #
    #
    module ModelExtensions

      # Check permission for the Model-Object
      #
      # permission  the requested permission (sample :create, :update, :destroy, :get)
      #
      # raise a SecurityError-Exception if access denied
      def check_access permission, *environment
        user = Thread.current[:user]
        unless AccessRules.model_access? user, self, permission, *environment
          raise SecurityError, "Access denied! Current user have no permission '#{permission}' on Model-Object #{self}."
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        # Bereinigen (entfernen) aller Objecte aus der angebenen Collection,
        # wo der akt. User nicht das angegebene Recht hat
        #
        # liefert ein neues Array mit den Objecten, wo der spez. Zugriff arlaubt ist
        def purge_collection collection, permission, *env
          user = Thread.current[:user]
          AccessRules.purge_collection(user, collection, permission, *env)
        end

      end # of ClassMethods

    end # of module ModelExtensions
  
end