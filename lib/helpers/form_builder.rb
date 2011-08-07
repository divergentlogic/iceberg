module Padrino
  module Helpers
    module FormBuilder
      class IcebergFormBuilder < StandardFormBuilder
        # Iceberg::MyModel -> iceberg-my_model
        def object_model_name(explicit_object=object)
          explicit_object.is_a?(Symbol) ? explicit_object : explicit_object.class.to_s.underscore.gsub(/\//, '-')
        end
      end
    end
  end
end
