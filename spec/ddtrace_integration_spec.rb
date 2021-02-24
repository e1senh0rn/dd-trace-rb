require 'spec_helper'

RSpec.describe 'ddtrace integration' do
  context 'after shutdown' do
    subject(:shutdown!) { Datadog.shutdown! }

    before { shutdown! }

    context 'calling public apis' do
      it 'does not error on tracing' do
        span = Datadog.tracer.trace('test')

        expect(span.finish).to be_truthy
      end

      it 'does not error on tracing with block' do
        value = Datadog.tracer.trace('test') do |span|
          expect(span).to be_a(Datadog::Span)
          :return
        end

        expect(value).to be(:return)
      end

      it 'does not error on logging' do
        expect(Datadog.logger.info('test')).to be_truthy
      end

      it 'does not error on configuration access' do
        expect(Datadog.configuration.diagnostics.debug).to be(false)
      end
    end
  end
end
