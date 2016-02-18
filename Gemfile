source "https://rubygems.org"

group :test do
  gem "json"
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec", '< 3.2.0'
  gem "rspec-core", "3.1.7"
  gem "rspec-puppet", "~> 2.1"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "hiera"
  gem "hiera-puppet-helper"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
end
