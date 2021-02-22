require 'ddtrace'

Datadog.configure do |c|
  c.diagnostics.debug = true
  c.analytics_enabled = true
  c.runtime_metrics.enabled = true
  c.use :rack, service_name: 'acme-rack'
end
