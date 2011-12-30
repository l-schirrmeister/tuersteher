module Tuersteher

  module AccessRule

    module Specification

      class Method
        
        attr_reader :negation, :registered_methods

        def initialize method, negation
          @registered_methods, @negation = [method], negation
        end

        def grant? path_or_model, method, login_ctx
          rc = @registered_methods.any? { |my_method| my_method == method }
          rc = !rc if @negation
          rc
        end

        def to_s
          "#{@negation && 'not.'}method(:#{@method})"
        end

      end

    end

  end

end