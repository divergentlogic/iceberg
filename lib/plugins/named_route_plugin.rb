Dir[File.dirname(__FILE__) + '/named_route_plugin/**/*.rb'].each {|file| load file }

module Iceberg
  module NamedRoutePlugin
    class RouteNotFound < RuntimeError; end
    
    def self.registered(app)
      app.set :named_routes, {}
      app.helpers Iceberg::NamedRoutePlugin::RoutingHelpers
      
      def register_route(name, &block)
        named_route = Iceberg::NamedRoutePlugin::NamedRoute.new(self, name)
        named_route.instance_eval(&block)
      end

      def route(verb, path, options={}, &block)
        if path.kind_of? Symbol
          route = named_routes[path]
          raise RouteNotFound.new("Route alias #{path.inspect} is not mapped to a url") unless route
          path = route[:path]
        end
        if path.kind_of? Array
          path.each { |p| super(verb, p, options, &block) }
        else
          super(verb, path, options, &block)
        end
      end
    end
  end
end
