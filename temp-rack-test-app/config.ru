require_relative 'app/datadog'
require_relative 'app/acme'

# use Datadog::Contrib::Rack::TraceMiddleware
run Acme::Application.new
