module Iceberg
  module Helpers
    module Utilities
      
      def split_splat
        params[:splat] ? params[:splat].first.split('/') : []
      end
      
    end
  end
end
