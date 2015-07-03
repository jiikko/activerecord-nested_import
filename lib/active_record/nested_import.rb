require "active_record/nested_import/version"
require "active_record/nested_import/importer"
require "activerecord-import/base"

if defined?(Rails)
  class Railtie < Rails::Railtie
    initializer 'initialize activerecord-nested_import' do
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.send(:include, ActiveRecord::NestedImport)
      end
    end
  end
else
  ::ActiveRecord::Base.send(:include, ActiveRecord::NestedImport)
end

module ActiveRecord
  module NestedImport
    def nested_import(association_name, attrs, options = {})
      Importer.new(self, association_name, attrs, options)
    end
  end
end
