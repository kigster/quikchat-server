require 'json'

namespace :deploy do
  before :starting, :load_slack_hooks do
    after 'deploy:starting', 'slack:start'
    after 'deploy:finished', 'slack:finish'
  end
end

namespace :slack do
  desc 'notify slack'
  task :start do
    post("#{user_name} started deploying quikchat-server to #{fetch(:rails_env)} from #{fetch(:branch)}...")
  end

  task :finish do
    post("#{user_name} finished deploying quikchat-server to #{fetch(:rails_env)}!")
  end

  def post(msg)
    uri = URI.parse('https://wanelo.slack.com/services/hooks/incoming-webhook?token=ED43Jt2ELutmqFF5aOAERUZ3')
    Net::HTTP.post_form(uri, payload: JSON.dump({text: msg}))
  end

  def user_name
    `git config --get user.name`
  end

end
