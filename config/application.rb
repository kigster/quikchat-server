require File.expand_path('../boot', __FILE__)

require 'rails'
require 'rails-api'
require 'pg'

# # Makara has an unrequired dependency on LogSubscriber
require 'active_record/log_subscriber'
require 'makara'

# We want to use AR and AC in our app
require 'active_record/railtie'
require 'action_controller/railtie'

# Turn things into JSON quickly
require 'oj'
require 'oj_mimic_json'
require 'flamegraph'
require 'compositor'

# Monitor all of that stuff
require 'newrelic_rpm' unless Rails.env.test?

module BabbleServer
  class Application < Rails::Application
  end
end

require Rails.root.join('lib', 'database_helper')
require Rails.root.join('app', 'compositors', 'conversation_compositor')
require Rails.root.join('app', 'compositors', 'message_compositor')
