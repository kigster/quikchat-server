class StatusController < ActionController::Metal
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  newrelic_ignore :check

  def check
    self.response_body = "OK"
  end
end
