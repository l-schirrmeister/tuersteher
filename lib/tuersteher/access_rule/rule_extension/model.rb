module Tuersteher

  module AccessRule

    module RuleExtension

      class Model < Base

        def initialize method_name, options = {}
          my_options = options.is_a?(String) ? {:value => [options]} : options
          super method_name, my_options
        end
        
        def to_s
          super { "Model" }
        end

        private

          #default options for this extension
          def default_options
            {:value => true, :object => true, :args => nil, :pass_args => false}
          end

          def used_object user, model
            model
          end

          def relation_object(user, model)
            user
          end

          def model_name user = nil, model = nil
            model.instance_of?(Class) ? "Class '#{model.name}'" : "Object '#{model.class}'"
          end

      end

    end

  end

end
