module ActiveRecord
  module NestedImport
    class Importer
      class BaseCollection
        attr_reader :association_name, :klass
        attr_accessor :prev_collection, :attrs, :ar_context

        def initialize(klass, attrs, association_name, ar_context)
          @association_name = association_name
          @klass = klass
          @ar_context = ar_context
          @attrs = attrs
          @new_records = []
          yield(self) if block_given?
        end

        def to_a
          setup
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

        def setup
          if persisted_records.empty?
            @new_records = build_records
          else
            persisted_records.each { |x|
              if (build_records.detect { |y| equal?(x, y) }).nil?
                @new_records.push(x)
              end
            }
          end
        end

        def build_records
          ar_context.public_send(association_name).build(attrs.uniq)
        end

      end

      class FirstCollection < BaseCollection
        def create_next_collection(klass, association_name)
          NextCollection.new(klass, attrs, association_name, ar_context) do |x|
            x.prev_collection = self
          end
        end

        private

        def persisted_records
          klass.where(collected_value_hash(attrs.uniq))
        end

        def equal?(x, y)
          # TODO [{ name: :hoge, no: 1 }, { name: :hoge, no: 1 }] => (x.name == y.name && x.no == y.no )
          @column_name ||= attrs.first.keys.first
          y.public_send(@column_name) == x.public_send(@column_name)
        end
      end

      class NextCollection < BaseCollection
        private

        def equal?(x, y)
          y.public_send("#{source_name}_id") == x.public_send("#{source_name}_id")
        end

        def attrs
          source_column_table = { id: "#{source_name}_id" }
          prev_collection.klass.where(
            collected_value_hash(@attrs) # @attrs がmiso
          ).map { |x| { source_column_table[:id] => x.id } }
        end

        def persisted_records
          ar_context.public_send(association_name).where(collected_value_hash(attrs))
        end

        def source_name
          ar_context.class.reflect_on_association(prev_collection.association_name).options[:source] || prev_collection.association_name.to_s.singularize
        end
      end

      def initialize(ar_context, association_name, attrs, options = {})
        association_options = ar_context.class.reflect_on_association(association_name).options
        klass = association_options[:class_name].constantize
        through_klass = ar_context.class.reflect_on_association(association_options[:through]).options[:class_name].constantize

        first_collection = FirstCollection.new(klass, attrs, association_name, ar_context)
        klass.import(first_collection.to_a, validate: false, timestamps: false)
        next_collection = first_collection.create_next_collection(through_klass, association_options[:through])
        through_klass.import(next_collection.to_a, validate: false, timestamps: false)
      end
    end
  end
end
