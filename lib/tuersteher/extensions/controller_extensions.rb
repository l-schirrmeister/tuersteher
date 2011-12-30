module Tuersteher
  
  # Module zum Include in Controllers
  # Dieser muss die folgenden Methoden bereitstellen:
  #
  #   current_user : akt. Login-User
  #   access_denied :  Methode aus dem authenticated_system, welche ein redirect zum login auslöst
  #
  # Der Loginuser muss fuer die hier benoetigte Funktionalitaet
  # die Methode:
  #   has_role?(role)  # role the Name of the Role as Symbol
  # besitzen.
  #
  # Beispiel der Einbindung in den ApplicationController
  #   include Tuersteher::ControllerExtensions
  #   before_filter :check_access # methode is from Tuersteher::ControllerExtensions
  #
  module ControllerExtensions

    @@url_path_method = nil
   
    # Pruefen Zugriff fuer eine Web-action
    #
    # path        Pfad der Webresource (String)
    # method      http-Methode (:get, :put, :delete, :post), default ist :get
    #
    def path_access?(path, method = :get)
      AccessRules.path_access? current_user, path, method
    end

    # Pruefen Zugriff auf ein Model-Object
    #
    # model       das Model-Object
    # permission  das geforderte Zugriffsrecht (:create, :update, :destroy, :get)
    #
    # liefert true/false
    def model_access? model, permission, *environment
      AccessRules.model_access? current_user, model, permission, *environment
    end

    # Bereinigen (entfernen) aller Objecte aus der angebenen Collection,
    # wo der akt. User nicht das angegebene Recht hat
    #
    # liefert ein neues Array mit den Objecten, wo der spez. Zugriff arlaubt ist
    def purge_collection collection, permission, *environment
      AccessRules.purge_collection(current_user, collection, permission, *environment)
    end

    def self.included(base)
      base.class_eval do
        # Diese Methoden  auch als Helper fuer die Views bereitstellen
        helper_method :path_access?, :model_access?, :purge_collection
      end
    end

    protected

    # Pruefen, ob Zugriff des current_user
    # fuer aktullen Request erlaubt ist
    def check_access
      
      ar_storage = AccessRulesStorage.instance
      unless ar_storage.ready?
        # bei nicht production-env check-intervall auf 5 sek setzen
        ar_storage.check_intervall = 5 if Rails.env!='production'
        # set root-path as prefix for all path rules
        prefix = respond_to?(:root_path) && root_path
        ar_storage.path_prefix = prefix if prefix && prefix.size > 1
        ar_storage.read_rules
      end

      # Rails3 hat andere url-path-methode
      @@url_path_method ||= Rails.version[0..1]=='3.' ? :fullpath : :request_uri

      # bind current_user on the current thread
      Thread.current[:user] = current_user

      req_method = request.method
      req_method = req_method.downcase.to_sym if req_method.is_a?(String)
      url_path = request.send(@@url_path_method)
      unless path_access?(url_path, req_method)
        usr_id = current_user && current_user.respond_to?(:id) ? current_user.id : current_user.object_id
        msg = "Tuersteher#check_access: access denied for #{url_path} :#{req_method} user.id=#{usr_id}"
        Tuersteher::TLogger.logger.warn msg
        logger.warn msg  # log message also for Rails-Default logger
        access_denied  # Methode aus dem authenticated_system, welche ein redirect zum login auslöst
      end
    end

  end  
  
end