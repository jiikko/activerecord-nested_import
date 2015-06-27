require "active_record/nested_import/version"

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
      collected_value_hash = ->(attrs) {
        {}.tap do |new_hash|
          attrs.each do |attr|
            attr.each do |key, value|
              new_hash[key] ||= []
              new_hash[key] << value
            end
          end
        end
      }

      association_options = self.class.reflect_on_association(association_name).options
      klass = association_options[:class_name].constantize # tag
      through_klass = self.class.reflect_on_association(association_options[:through]).options[:class_name].constantize
      records = self.public_send(association_name).build(attrs.uniq)
      # TODO deplicate keyになるので すでに登録されている場合に削除する必要gある
      preinsert_record = klass.where(collected_value_hash.call(attrs)) # まだいらなかった
      source_key = self.class.reflect_on_association(association_name).options[:source] || association_name.to_s.singularize
      source_column_table = { id: "#{source_key}_id" }
      through_attrs = klass.where(
        collected_value_hash.call(attrs)
      ).map do |x|
        { source_column_table[:id] => x.id }
      end
      through_records = self.public_send(association_options[:through]).build(through_attrs)
      ActiveRecord::Base.transaction do
        klass.import(records, validate: false, timestamps: false)
        through_klass.import(through_records, validate: false, timestamps: false)
      end
    end
  end
end
