require 'test_helper'
require 'action_controller/parameters'

class LogOnUnpermittedParamsTest < ActiveSupport::TestCase

  def teardown
    ActionController::Parameters.action_on_unpermitted_parameters = false
  end

  test "logs on unexpected params when action is set to :log " do
    params = ActionController::Parameters.new({
      :book => { :pages => 65 },
      :fishing => "Turnips"
    })

    ActionController::Parameters.action_on_unpermitted_parameters = :log
    assert_logged("Unpermitted parameters: fishing") do
      params.permit(:book => [:pages])
    end
  end

  test "logs on unexpected params when action is set to log with a log level" do
    params = ActionController::Parameters.new({
      :book => { :pages => 65 },
      :fishing => "Turnips"
    })

    ActionController::Parameters.action_on_unpermitted_parameters = :log
    assert_logged("Unpermitted parameters: fishing") do
      params.permit(:book => [:pages])
    end

    [:log_debug, :log_info, :log_warn, :log_error, :log_fatal].each do |log_level|
      ActionController::Parameters.action_on_unpermitted_parameters = log_level
      assert_logged("Unpermitted parameters: fishing") do
        params.permit(:book => [:pages])
      end
    end
  end

  test "logs on unexpected nested params when action is set to :log" do
    ActionController::Parameters.action_on_unpermitted_parameters = :log
    params = ActionController::Parameters.new({
      :book => { :pages => 65, :title => "Green Cats and where to find then." }
    })

    assert_logged("Unpermitted parameters: title") do
      params.permit(:book => [:pages])
    end
  end

  test "logs on unexpected nested params when action is set to log with a log level" do
    params = ActionController::Parameters.new({
      :book => { :pages => 65, :title => "Green Cats and where to find then." }
    })

    [:log_debug, :log_info, :log_warn, :log_error, :log_fatal].each do |log_level|
      assert_logged("Unpermitted parameters: title") do
        ActionController::Parameters.action_on_unpermitted_parameters = log_level
        params.permit(:book => [:pages])
      end
    end
  end

  private

  def assert_logged(message)
    old_logger = ActionController::Base.logger
    log = StringIO.new
    ActionController::Base.logger = Logger.new(log)

    begin
      yield

      log.rewind
      assert_match message, log.read
    ensure
      ActionController::Base.logger = old_logger
    end
  end
end