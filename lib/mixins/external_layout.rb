module Iceberg
  module Mixins
    module ExternalLayout
      def self.included(base)
        base.class_eval do
          private
      
          def render_with_external_layout(engine, data, options={}, locals={}, &block)
            unless options[:layout]
              options.merge!({:layout => self.options.external_layout}) if self.options.respond_to?(:external_layout) && self.options.external_layout
            end
            render_without_external_layout(engine, data, options, locals, &block)
          end
          alias_method :render_without_external_layout, :render
          alias_method :render, :render_with_external_layout
        end
      end
    end
  end
end
