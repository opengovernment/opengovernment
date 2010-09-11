module RSpec::Rails
  module IntegrationExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include ActionView::TestCase::Behavior
    include RSpec::Rails::RailsExampleGroup
    include RSpec::Rails::BrowserSimulators
    include RSpec::Rails::Matchers::RoutingMatchers
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate


    webrat do
      include Webrat::Matchers
      include Webrat::Methods
    end

    capybara do
      include Capybara
    end

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
      metadata[:render_views] = true

      before do
        @router = ::Rails.application.routes
      end

      webrat do
        Webrat.configure do |config|
          config.mode = :rack
        end
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','integration')
  end
end
