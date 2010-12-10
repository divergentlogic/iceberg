module Iceberg
  module Filters
    def filters
      @filters ||= []
    end

    def filter_on(model_attribute, user_attribute)
      filters << [model_attribute, user_attribute]
    end

    def filtered(user, options={})
      proxy = self
      options_from_filters(user).each { |opt| proxy = proxy.all(:conditions => opt) }
      proxy.all(options)
    end

    def options_from_filters(user)
      options = []
      filters.each do |f|
        options << parse_filter(f, user)
      end
      options
    end

    def parse_filter(filter, user)
      model_attribute, user_attribute = filter
      user_value = Array(user.send(user_attribute))
      ["#{storage_name}.#{model_attribute} IN ? OR #{storage_name}.#{model_attribute} IS NULL", user_value]
    end
  end
end
