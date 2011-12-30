module Tuersteher
  
  class AccessRules
    class << self

      # Pruefen Zugriff fuer eine Web-action
      # user        User, für den der Zugriff geprüft werden soll (muss Methode has_role? haben)
      # path        Pfad der Webresource (String)
      # method      http-Methode (:get, :put, :delete, :post), default ist :get
      #
      def path_access?(user, path, method = :get)
        rule = AccessRulesStorage.instance.path_rules.detect do |r|
          r.fired?(path, method, user)
        end
        if Tuersteher::TLogger.logger.debug?
          if rule.nil?
            s = 'denied'
          else
            s = "fired with #{rule}"
          end
          usr_id = user && user.respond_to?(:id) ? user.id : user.object_id
          Tuersteher::TLogger.logger.debug("Tuersteher: path_access?(user.id=#{usr_id}, path=#{path}, method=#{method})  =>  #{s}")
        end
        !(rule.nil? || rule.deny?)
      end


      # Pruefen Zugriff auf ein Model-Object
      #
      # user        User, für den der Zugriff geprüft werden soll (muss Methode has_role? haben)
      # model       das Model-Object
      # permission  das geforderte Zugriffsrecht (:create, :update, :destroy, :get) 
      # environment beliebige Argumente, die an eine mögliche RuleExtension weitergegeben werden können
      #
      # liefert true/false
      def model_access? user, model, permission, *environment
        raise "Wrong call! Use: model_access(model-instance-or-class, permission)" unless permission.is_a? Symbol
        return false unless model

        rule = AccessRulesStorage.instance.model_rules.detect do |rule|
          rule.fired? model, permission, user, environment
        end
        access = rule && !rule.deny?
        if Tuersteher::TLogger.logger.debug?
          usr_id = user && user.respond_to?(:id) ? user.id : user.object_id
          if model.instance_of?(Class)
            Tuersteher::TLogger.logger.debug(
              "Tuersteher: model_access?(user.id=#{usr_id}, model=#{model}, permission=#{permission}) =>  #{access || 'denied'} #{rule}")
          else
            Tuersteher::TLogger.logger.debug(
              "Tuersteher: model_access?(user.id=#{usr_id}, model=#{model.class}(#{model.respond_to?(:id) ? model.id : model.object_id }), permission=#{permission}) =>  #{access || 'denied'} #{rule}")
          end
        end
        access
      end

      # Bereinigen (entfernen) aller Objecte aus der angebenen Collection,
      # wo der angegebene User nicht das angegebene Recht hat
      #
      # liefert ein neues Array mit den Objecten or arguments, wo der spez. Zugriff arlaubt ist
      #
      # If you want to test the object with special args, you have to give the collection as an array of arrays.
      # It should have the following form => [ [model1, [args_for_model1]], [model2, [args_for_model2]], ... ]
      # For that last case you have to give {:with_value => true} as env
      def purge_collection user, collection, permission, *env
        if collection.is_a?(Array) #the list is given as collection
          if env.empty? #just a list of model-objects for testing
            access_collection = collection.select { |model| model_access?(user, model, permission) }
          elsif env.size == 1 && env.first.is_a?(Hash) && env.first[:with_args] #the list contains arrays like this [model, [*args]]
            access_collection = collection.select do |model|
              env = model.is_a?(Array) ? model.last : []
              my_model = model.is_a?(Array) ? model.first : model
              model_access?(user, my_model, permission, *env)
            end 
          else #env is given as the arg for a list models
            access_collection = collection.select { |model| model_access?(user, model, permission, *env) }
          end
        else #single model and a list of args [[*args1], [*args2]]
          return [] if env.empty? || env.size != 1 || !env.first.is_a?(Array)
          env.first.select { |args| model_access?(user, collection, permission, *args) }
        end
      end #purge_collection

    end # of Class-Methods

  end # of AccessRules
  
end