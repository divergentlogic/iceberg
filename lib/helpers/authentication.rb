module Iceberg
  module Helpers
    module Authentication
      
      def warden
        request.env['warden']
      end

      def authenticated?(*args)
        warden.authenticated?(*args)
      end
      alias_method :logged_in?, :authenticated?
      alias_method :signed_in?, :authenticated?

      def user(*args)
        warden.user(*args)
      end
      alias_method :current_user, :user

      def user=(user)
        warden.set_user user
      end
      alias_method :current_user=, :user=

      def logout(*args)
        warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
        warden.logout(*args)
      end

      def authenticate(*args)
        warden.authenticate(*args)
      end

      def authenticate!(*args)
        warden.authenticate!(*args)
      end
      
    end
  end
end
