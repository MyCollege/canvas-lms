group :development do
  # gem 'newrelic_rpm'  # do not run on background server - kills imports
  gem "sentry-raven", :git => "https://github.com/getsentry/raven-ruby.git"
end
