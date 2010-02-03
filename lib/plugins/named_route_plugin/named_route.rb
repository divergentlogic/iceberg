module Iceberg
  module NamedRoutePlugin
    class NamedRoute
      def initialize(app, name)
        @app  = app
        @name = name
        @app.named_routes[@name] ||= {}
      end
      
      def path(path)
        path = [path] unless path.kind_of? Array
        path.each do |p|
          (@app.named_routes[@name][:path]    ||= []) << p
          (@app.named_routes[@name][:matcher] ||= []) << @app.send(:compile, p).first
        end
      end
      
      def generate(path=nil, &block)
        if path && !block_given?
          @app.named_routes[@name][:generator] = path
        elsif block_given?
          @app.named_routes[@name][:generator] = block
        else
          raise "Must provide path or block"
        end
      end
    end
  end
end
