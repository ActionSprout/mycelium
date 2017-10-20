source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '~> 5.0.4'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'

# Tools
gem 'sidekiq', '~> 4'
gem 'sidekiq-pro', source: "https://2aa2eab4:95d80c19@enterprise.contribsys.com/"
gem 'sidekiq-ent', source: "https://2aa2eab4:95d80c19@enterprise.contribsys.com/"

# We need sinatra for Sidekiq's UI.
# We are using Github (master) version because we're on Rails 5.
# REF => https://github.com/mperham/sidekiq/issues/2839#issuecomment-191723849
gem 'sinatra', github: 'sinatra', :require => nil


group :development, :test do
  gem 'dotenv-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'rb-fsevent', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'foreman'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
end

group :production do
  gem 'lograge'
end
