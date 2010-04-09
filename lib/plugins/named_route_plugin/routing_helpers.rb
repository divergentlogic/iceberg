module Iceberg
  module NamedRoutePlugin
    module RoutingHelpers
      def path_for(name, *args)
        query = get_query(*args)
        "#{request.script_name}#{get_url_fragment(name, *args)}#{query}"
      end

      def url_for(name, *args)
        scheme = request.scheme
        if (scheme == 'http' && request.port == 80 ||
            scheme == 'https' && request.port == 443)
          port = ""
        else
          port = ":#{request.port}"
        end
        query = get_query(*args)
        "#{scheme}://#{request.host}#{port}#{request.script_name}#{get_url_fragment(name, *args)}#{query}"
      end

      def current_path_matches?(name)
        route   = get_route(name)
        matcher = route[:matcher]
        matcher.each do |match|
          return true if request.path_info =~ match
        end
        false
      end

    private

      def get_url_fragment(name, *args)
        route = get_route(name)
        generator = route[:generator]
        if generator.respond_to?(:call)
          generator.call(*args)
        else
          generator
        end
      end

      def get_route(name)
        route = self.class.named_routes[name]
        raise Iceberg::NamedRoutePlugin::RouteNotFound.new("Route alias #{name.inspect} is not mapped to a url") unless route
        route
      end

      def get_query(*args)
        options = get_options(*args)
        options[:query] ? "?#{options[:query].map {|k,v| "#{CGI::escape(k)}=#{CGI::escape(v)}"}.join('&')}" : nil
      end

      def get_options(*args)
        args.last.is_a?(Hash) ? args.last : {}
      end
    end
  end
end
