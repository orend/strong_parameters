module StrongParameters
  class LogSubscriber < ActiveSupport::LogSubscriber
    def unpermitted_parameters(event)
      unpermitted_keys = event.payload[:keys]
      request_info = event.payload[:request_info]
      debug("Unpermitted parameters: #{unpermitted_keys.join(", ")} in #{request_info[:controller]}##{request_info[:action]}")
    end

    def logger
      ActionController::Base.logger
    end
  end
end

StrongParameters::LogSubscriber.attach_to :action_controller
