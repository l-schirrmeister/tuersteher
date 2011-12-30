module Tuersteher

  module AccessRule

    module Specification

      class Role
        
        attr_reader :roles, :negation

        def initialize role, negation
          @negation = negation
          @roles = [role]
        end

        def grant? path_or_model, method, login_ctx
          return false if login_ctx.nil?
          # roles sind or verknüpft
          rc = @roles.any? { |role| login_ctx.has_role?(role) }
          rc = !rc if @negation
          rc
        end

        def to_s
          role_s = @roles.size == 1 ? "role(:#{@roles.first})" : "roles(#{@roles.map{|r| ":#{r}"}.join(',')})"
          "#{@negation && 'not.'}#{role_s}"
        end

      end

    end

  end

end