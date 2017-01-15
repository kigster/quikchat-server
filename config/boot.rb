# In production, the deployment shared bundle is in vendor/bundle
vendored_bundle = File.expand_path('../../vendor/bundle/bundler/setup.rb', __FILE__)
if File.exist?(vendored_bundle)
  require vendored_bundle
else
  require File.expand_path('../../.bundle/bundler/setup', __FILE__)
end

require_relative "rubygems_shim"
