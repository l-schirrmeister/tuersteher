module Tuersteher

  module AccessRule

    module Specification

      class Model

        def initialize clazz, negation
          clazz = clazz.name if clazz.is_a?(Class)
          @clazz, @negation = clazz, negation
        end

        def grant? path_or_model, method, login_ctx
          m_class = path_or_model.instance_of?(Class) ? path_or_model.name : path_or_model.class.name
          rc = @clazz == m_class
          rc = !rc if @negation
          rc
        end

        def to_s
          "#{@negation && 'not.'}model(#{@clazz})"
        end

      end

    end

  end

end