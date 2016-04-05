source 'https://rubygems.org'

# Specify your gem's dependencies in contextuable.gemspec
gemspec

group :development, :test do
  gem 'rspec', require: false
  gem 'simplecov', require: false
  gem 'rubocop', '~> 0.37.2', require: false unless RUBY_VERSION =~ /^1.8/
  gem 'coveralls'
  gem 'codeclimate-test-reporter'

  platforms :mri, :mingw do
    gem 'pry', require: false
    gem 'pry-coolline', require: false
  end
end
