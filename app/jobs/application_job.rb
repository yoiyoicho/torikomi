class ApplicationJob < ActiveJob::Base
  # Active JobでURLヘルパーを使えるようにする
  include Rails.application.routes.url_helpers

  protected

  def default_url_options
    Rails.application.config.action_controller.default_url_options
  end
end
