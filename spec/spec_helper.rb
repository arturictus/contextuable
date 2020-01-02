$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'contextuable'
require 'pry'

require 'coveralls'
require 'codeclimate-test-reporter'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
]

SimpleCov.start

require 'rubocop/rake_task'
RuboCop::RakeTask.new
Rake::Task['rubocop'].invoke
