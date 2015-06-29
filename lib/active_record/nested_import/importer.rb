module ActiveRecord
  module NestedImport
    class Importer
      def initialize(context, association_name, attrs, options = {})
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

        association_options = context.class.reflect_on_association(association_name).options
        klass = association_options[:class_name].constantize # tag
        build_records = context.public_send(association_name).build(attrs.uniq)
        persisted_records = klass.where(collected_value_hash.call(attrs.uniq))
        new_records = []
        if persisted_records.empty?
          new_records = build_records
        else
          persisted_records.each { |x| new_records.push(x) unless build_records.detect { |y| y.name == x.name } }
        end
        klass.import(new_records, validate: false, timestamps: false)
        through_klass = context.class.reflect_on_association(association_options[:through]).options[:class_name].constantize
        source_key = context.class.reflect_on_association(association_name).options[:source] || association_name.to_s.singularize
        source_column_table = { id: "#{source_key}_id" }
        through_attrs = klass.where(
          collected_value_hash.call(attrs)
        ).map { |x| { source_column_table[:id] => x.id } }
        raise('it be wrong') if through_attrs.empty?
        through_new_records = []
        through_build_records = context.public_send(association_options[:through]).build(through_attrs)
        through_persisted_records = context.send(association_options[:through]).where(collected_value_hash.call(through_attrs))
        if through_persisted_records.empty?
          through_new_records = through_build_records
        else
          through_persisted_records.each { |x| through_new_records.push(x) unless through_build_records.detect { |y| y.tag_id == x.tag_id } }
        end
        through_klass.import(through_new_records, validate: false, timestamps: false)
      end

      def import!
      end
    end
  end
end
