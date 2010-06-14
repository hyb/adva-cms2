$: << File.expand_path('../../lib', __FILE__)
$: << File.expand_path('../../app/models', __FILE__)

require 'rubygems'
require 'bundler'

Bundler.setup

require 'active_record'
require 'test/unit'
require 'test_declarative'
require 'database_cleaner'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.up(File.expand_path('../../db/migrate', __FILE__))

DatabaseCleaner.strategy = :truncation

require 'site'
require 'section'
require 'page'
require 'content'
require 'article'

class Test::Unit::TestCase
  def teardown
    DatabaseCleaner.clean
  end
end