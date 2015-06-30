module ActiveRecord
  module NestedImport
    class Importer
      class BaseCollection
        attr_accessor :association_name, :klass

        def to_a
          @new_records
        end

        private

        def collected_value_hash(attrs)
          {}.tap { |new_hash|
            attrs.each do |attr|
              attr.each do |key, value|
                new_hash[key] ||= []
                new_hash[key] << value
              end
            end
          }
        end
      end

      class FirstCollection < BaseCollection
        def initialize(klass, attrs, association_name, ar_context)
          @association_name = association_name
          @klass = klass
          build_records = ar_context.public_send(association_name).build(attrs.uniq)
          persisted_records = klass.where(collected_value_hash(attrs.uniq))

          @new_records = []
          if persisted_records.empty?
            @new_records = build_records
          else
            persisted_records.each { |x|
              if (build_records.detect { |y| y.name == x.name }).nil?
                @new_records.push(x)
              end
            }
          end
        end
      end

      class NextCollection < BaseCollection
        def initialize(klass, attrs, association_name, ar_context, prev_collection)
          through_klass = ar_context.class.reflect_on_association(association_name).options[:class_name].constantize
          source_key = ar_context.class.reflect_on_association(prev_collection.association_name).options[:source] || prev_collection.association_name.to_s.singularize
          source_column_table = { id: "#{source_key}_id" }
          through_attrs = prev_collection.klass.where(
            collected_value_hash(attrs)
          ).map { |x| { source_column_table[:id] => x.id } }
          raise('it be wrong') if through_attrs.empty?

          @new_records = []
          through_build_records = ar_context.public_send(association_name).build(through_attrs)
          through_persisted_records = ar_context.send(association_name).where(collected_value_hash(through_attrs))

          if through_persisted_records.empty?
            @new_records = through_build_records
          else
            through_persisted_records.each { |x|
              if (through_build_records.detect { |y| y.tag_id == x.tag_id } ).nil?
                @new_records.push(x)
              end
            }
          end
        end
      end

      def initialize(ar_context, association_name, attrs, options = {})
        association_options = ar_context.class.reflect_on_association(association_name).options
        klass = association_options[:class_name].constantize # tag
        first_collection = FirstCollection.new(klass, attrs, association_name, ar_context)
        klass.import(first_collection.to_a, validate: false, timestamps: false)

        through_klass = ar_context.class.reflect_on_association(association_options[:through]).options[:class_name].constantize
        next_collection = NextCollection.new(through_klass, attrs, association_options[:through], ar_context, first_collection)
        through_klass.import(next_collection.to_a, validate: false, timestamps: false)
      end

      def import!
      end
    end
  end
end
