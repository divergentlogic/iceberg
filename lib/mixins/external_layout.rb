module Iceberg
  module Mixins
    module ExternalLayout
      def self.included(base)
        base.class_eval do
          private
          
          def render(engine, data, options={}, locals={}, &block)
            unless options[:layout]
              options.merge!({:layout => self.options.external_layout}) if self.options.respond_to?(:external_layout) && self.options.external_layout
            end
            super(engine, data, options, locals, &block)
          end
        end
      end
    end
  end
end
