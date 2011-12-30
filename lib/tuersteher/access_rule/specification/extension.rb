module Tuersteher

  module AccessRule

    module Specification

      class Extension

        def initialize method_name, negation, expected_value=nil
          @method, @negation, @expected_value = method_name, negation, expected_value
        end

        def grant? path_or_model, method, login_ctx
          rc = false
          if path_or_model.is_a?(String)
            # path-variante
            return false if login_ctx.nil?
            unless login_ctx.respond_to?(@method)
              Tuersteher::TLogger.logger.warn("#{to_s}.grant? => false why Login-Context have not method '#{@method}'!")
              return false
            end
            if @expected_value
              rc = login_ctx.send(@method, @expected_value)
            else
              rc = login_ctx.send(@method)
            end
          else
            # model-variante
            unless path_or_model.respond_to?(@method)
              m_msg = path_or_model.instance_of?(Class) ? "Class '#{path_or_model.name}'" : "Object '#{path_or_model.class}'"
              Tuersteher::TLogger.logger.warn("#{to_s}.grant? => false why #{m_msg} have not method '#{@method}'!")
              return false
            end
            if @expected_value
              rc = path_or_model.send(@method, login_ctx, @expected_value)
            else
              rc = path_or_model.send(@method, login_ctx)
            end
          end
          rc = !rc if @negation
          rc
        end

        def to_s
          val_s = @expected_value.nil? ? nil :  ", #{@expected_value}"
          "#{@negation && 'not.'}extension(:#{@method}#{val_s})"
        end

      end

    end

  end

end