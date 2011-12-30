module Tuersteher

  module AccessRule

    class Path < Base

      METHOD_NAMES = [:get, :edit, :put, :delete, :post, :all].freeze
      attr_reader :path_spezification

      # Zugriffsregel
      #
      # path          :all fuer beliebig, sonst String mit der http-path beginnen muss
      #
      def initialize(path)
        raise "wrong path '#{path}'! Must be a String or :all ." unless path==:all or path.is_a?(String)
        super()
        if path != :all # :all is only syntax sugar
          @path_spezification = Specification::Path.new(path, @negation)
          @rule_spezifications << @path_spezification
        end
      end

      def path= url_path
        @path = url_path
        if url_path != :all
          # path in regex ^#{path} wandeln ausser bei "/",
          # dies darf keine Regex mit ^/ werden,
          # da diese ja immer matchen wuerde
          if url_path == "/"
            @path_regex = /^\/$/
          else
            @path_regex = /^#{url_path}/
          end
        end
      end

      # set http-methode
      # http_method        http-Method, allowed is :get, :put, :delete, :post, :all
      def method(http_method)
        raise "wrong method '#{http_method}'! Must be #{METHOD_NAMES.join(', ')} !" unless METHOD_NAMES.include?(http_method)
        super
        self
      end

      def methods(*http_methods)
        raise "wrong method '#{http_method}'! Must be #{METHOD_NAMES.join(', ')} !" unless access_methods.flatten.all? { |http_method| METHOD_NAMES.include?(http_method) }
        super
        self
      end

      def to_s
        @_to_s ||= super
      end

    end

  end

end