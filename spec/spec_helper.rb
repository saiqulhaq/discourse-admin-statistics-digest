if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'rubygems'
require 'spork'

PLUGIN_PATH = 'plugins/discourse-admin-statistics-digest'.freeze unless defined?(PLUGIN_PATH)

Spork.prefork do
  require 'fabrication'
  ENV['RAILS_ENV'] ||= 'test'
  require File.expand_path('../../../../config/environment', __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
  Dir[Rails.root.join('spec/fabricators/*.rb')].each {|f| require f}

  Dir[Rails.root.join(PLUGIN_PATH, 'spec/support/**/*.rb')].each {|f| require f}

  SeedFu.fixture_paths = [Rails.root.join("#{PLUGIN_PATH}/spec/fixtures")]

  SiteSetting.automatically_download_gravatars = false

  SeedFu.seed

  RSpec.configure do |config|
    config.fail_fast = ENV['RSPEC_FAIL_FAST'] == '1'
    config.include Helpers

    config.order = 'random'

    config.infer_spec_type_from_file_location!

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = true

    config.before(:suite) do

      Sidekiq.error_handlers.clear

      # Ugly, but needed until we have a user creator
      User.skip_callback(:create, :after, :ensure_in_trust_level_group)

      DiscoursePluginRegistry.clear if ENV['LOAD_PLUGINS'] != '1'

      Discourse.current_user_provider = TestCurrentUserProvider

      SiteSetting.refresh!

      # Rebase defaults
      #
      # We nuke the DB storage provider from site settings, so need to yank out the existing settings
      #  and pretend they are default.
      # There are a bunch of settings that are seeded, they must be loaded as defaults
      SiteSetting.current.each do |k,v|
        SiteSetting.defaults[k] = v
      end

      require_dependency 'site_settings/local_process_provider'
      SiteSetting.provider = SiteSettings::LocalProcessProvider.new
    end

    class DiscourseMockRedis < MockRedis
      def without_namespace
        self
      end

      def delete_prefixed(prefix)
        keys("#{prefix}*").each { |k| del(k) }
      end
    end

    config.before :each do |x|
      # TODO not sure about this, we could use a mock redis implementation here:
      #   this gives us really clean "flush" semantics, howere the side-effect is that
      #   we are no longer using a clean redis implementation, a preferable solution may
      #   be simply flushing before tests, trouble is that redis may be reused with dev
      #   so that would mean the dev would act weird
      #
      #   perf benefit seems low (shaves 20 secs off a 4 minute test suite)
      #
      # $redis = DiscourseMockRedis.new
      #
      # disable all observers, enable as needed during specs
      #
      ActiveRecord::Base.observers.disable :all
      SiteSetting.provider.all.each do |setting|
        SiteSetting.remove_override!(setting.name)
      end

      # very expensive IO operations
      SiteSetting.automatically_download_gravatars = false

      Discourse.clear_readonly!

      I18n.locale = :en
    end

    class TestCurrentUserProvider < Auth::DefaultCurrentUserProvider
      def log_on_user(user,session,cookies)
        session[:current_user_id] = user.id
        super
      end

      def log_off_user(session,cookies)
        session[:current_user_id] = nil
        super
      end
    end

  end



end

require_relative '../../discourse-admin-statistics-digest/lib/admin_statistics_digest'

Spork.each_run do
  Discourse.after_fork
end

