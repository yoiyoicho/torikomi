require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Torikomi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    #rails gコマンドで生成するファイルの設定
    config.generators do |g|
      g.helper false #ヘルパーファイルを生成しない
      g.test_framework :rspec, #rspecの設定
        fixtures: false,
        routing_specs: false,
        view_specs: false,
        helper_specs: false,
        controller_specs: true,
        request_specs: false
    end

    #デフォルトのlocaleを日本語にする
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    #デフォルトのタイムゾーンを日本にする
    config.time_zone = 'Tokyo'

    # Active Jobをsidekiqで実行する
    config.active_job.queue_adapter = :sidekiq
  end
end
