module Tuersteher

  module AccessRule

    module RuleExtension

      class User < Base

        def to_s
          super { "User" }
        end

        private

          def used_object user, model
            user
          end

          def relation_object(user, model)
            model
          end

          def model_name user, model
            "current_user"
          end

      end

    end

  end

end
