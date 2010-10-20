module Iceberg
  module Filters
    def filter_on(board_attribute, user_attribute)
      @filters ||= []
      @filters << [board_attribute, user_attribute]
    end

    def filtered(user, options={})
      all(options.merge(options_from_filters(user)))
    end

    def options_from_filters(user)
      options = {}
      @filters.each do |f|
        parse_filter(options, f, user)
      end
      options
    end

    def parse_filter(options, filter, user)
      board_attributes = Array(filter[0])
      subhash = options
      size = board_attributes.size
      board_attributes.each_with_index do |attr, index|
        if index == size - 1 
          subhash[attr] = user_values(user, filter[1])
        end
        subhash[attr] ||= { }
        subhash = subhash[attr]
        subhash
      end
      options
    end

    def user_values(user, user_attributes)
      obj = Array(user)
      Array(user_attributes).each do |u|
        obj = obj.map { |o| Array(o.send(u)) }.flatten
      end
      obj
    end
  end
end
