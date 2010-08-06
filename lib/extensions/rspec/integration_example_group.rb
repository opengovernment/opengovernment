module RSpec::Rails
  module IntegrationExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include ActionDispatch::Integration::Runner
    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionDispatch::Assertions
    include Webrat::Matchers
    include Webrat::Methods
    include RSpec::Matchers
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    module InstanceMethods
      def app
        ::Rails.application
      end

      def last_response
        response
      end
    end

    included do
      metadata[:type] = :integration

      before do
        @router = ::Rails.application.routes
      end

      Webrat.configure do |config|
        config.mode = :rack
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','integration')
  end
end
