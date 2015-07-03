$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'active_record'
require "activerecord-import/base"
require 'activerecord/nested_import'
require 'acts-as-taggable-on'
require 'internal/app/models/user'
require 'internal/app/models/scratch_tag'
require 'internal/app/models/scratch_tagging'

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Import.require_adapter('mysql2')

ActiveRecord::Base.establish_connection(
  adapter:   'sqlite3',
  database:  ':memory:'
)
ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
