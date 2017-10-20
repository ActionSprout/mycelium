require 'sidekiq/pro/web'

unless ENV['SIDEKIQ_VERBOSE'].present?
  Sidekiq::Logging.logger.level = Logger::WARN
end

# Add Basic Auth for Sidekiq UI
sidekiq_username = ENV['SIDEKIQ_USERNAME']
sidekiq_password = ENV['SIDEKIQ_PASSWORD']

if sidekiq_username.present? && sidekiq_password.present?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(sidekiq_username)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(sidekiq_password))
  end
end

# Sidekiq Reliability
# https://github.com/mperham/sidekiq/wiki/Reliability
Sidekiq::Client.reliable_push! unless Rails.env.test?
Sidekiq.configure_server do |config|
  # TODO: When super_fetch become mature we can switch to that algorithm.
  # config.super_fetch!
  config.timed_fetch!

  config.reliable_scheduler!

  if ENV['RUN_PERIODIC_JOBS'].present?
    # Ent Periodic Jobs (https://github.com/mperham/sidekiq/wiki/Ent-Periodic-Jobs)
    # Note: The Rails App is configured for Facebook Timezone but CRON jobs and server
    #       are still in UTC.
    config.periodic do |mgr|
      # Example: Run everyday at 02:00 Pacific Time.
      # mgr.register '0 10 * * *', CreateAllMissingPageMetricsJob
    end
  end
end
