module Tuersteher

  module AccessRule

    module Specification

      class Path
        
        attr_reader :path

        def initialize path, negation
          @negation = negation
          self.path = path
        end

        def path= url_path
          @path = url_path
          # url_path in regex ^#{path} wandeln ausser bei "/",
          # dies darf keine Regex mit ^/ werden, da diese dann ja immer matchen wuerde
          if url_path == "/"
            @path_regex = /^\/$/
          else
            @path_regex = /^#{url_path}/
          end
        end

        def grant? path_or_model, method, login_ctx
          rc = @path_regex =~ path_or_model
          rc = !rc if @negation
          rc
        end

        def to_s
          "#{@negation && 'not.'}path('#{@path}')"
        end

      end

    end

  end

end