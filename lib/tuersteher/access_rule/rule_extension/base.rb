module Tuersteher

  module AccessRule

    module RuleExtension

      class Base

        def initialize method_name, options = {}
          check_given_options options
          @options = default_options.merge(options)
          @method_name = method_name
        end

        def grant? user, model, environment, rule
          return false unless object_responds_to_method?(used_object(user, model), model_name(user,model), rule)
          begin
            return used_object(user, model).send(*args_for_call(user, model, environment)) == value
          rescue ArgumentError => e
            rule.log_for_wrong_number_of_arguments(model_name(user, model), method_name, environment, e)
            return false
          end
        end

        attr_reader :method_name

        def object?
          @options[:object]
        end

        def args_given?
          !args.nil?
        end

        def args
          @options[:args]
        end

        def pass_args?
          @options[:pass_args]
        end

        def value
          @options[:value]
        end

        def to_s
          "RuleExtension: " + yield + ", medhod: #{@method_name}, options: #{@options.inspect}"
        end

        private

          #all allowed options for this extension
          def allowed_options
            [:value, :object, :args, :pass_args]
          end

          #default options for this extension
          def default_options
            {:value => true, :object => false, :args => nil, :pass_args => false}
          end

          #checks if all options are allowed for this extension
          def check_given_options options
            unless (unknown_keys = options.keys.select { |option_key| !allowed_options.include?(option_key) }).empty?
              raise "option #{ unknown_keys.join(", ") } not known"
            end
          end

          #tests if the extension object reponds to the given method_name and logs otherwise the problem
          def object_responds_to_method? my_object, my_model_name, rule
            if my_object.respond_to?(method_name)
              return true
            else
              rule.log_for_no_method(my_model_name, method_name)
              return false
            end
          end

          #returns the arg for the method call on the extension object
          def args_for_call user, model, environment
            my_args = [method_name]
            my_args.push(relation_object(user, model)) if object?
            my_args.push(*args) if args_given?
            my_args.push(*environment) if pass_args?
            my_args
          end

      end

    end

  end

end