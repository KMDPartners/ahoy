module Ahoy
  module Controller
    def self.included(base)
      if base.respond_to?(:helper_method)
        base.helper_method :current_visit
        base.helper_method :ahoy
      end
      base.before_action :set_ahoy_cookies, unless: -> { Ahoy.api_only }
      base.before_action :track_ahoy_visit, unless: -> { Ahoy.api_only }
      base.around_action :set_ahoy_request_store
    end

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self)
    end

    def current_visit
      ahoy.visit
    end

    def set_ahoy_cookies
      if Ahoy.cookies
        ahoy.set_visitor_cookie
        ahoy.set_visit_cookie
      else
        # delete cookies if exist
        ahoy.reset
      end
    end

    def track_ahoy_visit
      defer = Ahoy.server_side_visits != true

      if defer && !Ahoy.cookies
        # avoid calling new_visit?, which triggers a database call
      elsif ahoy.new_visit?
        ahoy.track_visit(defer: defer)
      end
    end

    def set_ahoy_request_store
      previous_value = Thread.current[:ahoy]
      begin
        Thread.current[:ahoy] = ahoy
        yield
      ensure
        Thread.current[:ahoy] = previous_value
      end
    end
  end
end
