module ActiveRecord
  module NestedImport
    class Importer
      class BaseCollection
        attr_reader :association_name, :klass
        attr_accessor :prev_collection, :attrs, :ar_context
        attr_accessor :through_attrs


        def initialize(klass, attrs, association_name, ar_context)
          @association_name = association_name
          @klass = klass
          @ar_context = ar_context
          @attrs = attrs
          @new_records = []
          yield(self) if block_given?
        end

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

        def build_records
          ar_context.public_send(association_name).build(attrs.uniq)
        end
      end

      class FirstCollection < BaseCollection
        def initialize(klass, attrs, association_name, ar_context)
          super
        end

        def setup
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

        def persisted_records
          klass.where(collected_value_hash(attrs.uniq))
        end

        def create_next_collection(klass, association_name)
          collection = NextCollection.new(klass, attrs, association_name, ar_context) do |x|
            x.prev_collection = self
          end
          collection
        end
      end

      class NextCollection < BaseCollection
        def setup
          if persisted_records.empty?
            @new_records = build_records
          else
            persisted_records.each { |x|
              if (build_records.detect { |y| y.tag_id == x.tag_id } ).nil?
                @new_records.push(x)
              end
            }
          end
        end

        def attrs
          source_key = ar_context.class.reflect_on_association(prev_collection.association_name).options[:source] || prev_collection.association_name.to_s.singularize
          source_column_table = { id: "#{source_key}_id" }
          prev_collection.klass.where(
            collected_value_hash(@attrs) # @attrs がmiso
          ).map { |x| { source_column_table[:id] => x.id } }
        end

        def persisted_records
          ar_context.send(association_name).where(collected_value_hash(attrs))
        end
      end

      def initialize(ar_context, association_name, attrs, options = {})
        association_options = ar_context.class.reflect_on_association(association_name).options
        klass = association_options[:class_name].constantize
        through_klass = ar_context.class.reflect_on_association(association_options[:through]).options[:class_name].constantize

        first_collection = FirstCollection.new(klass, attrs, association_name, ar_context)
        first_collection.setup
        klass.import(first_collection.to_a, validate: false, timestamps: false)
        next_collection = first_collection.create_next_collection(through_klass, association_options[:through])
        next_collection.setup
        through_klass.import(next_collection.to_a, validate: false, timestamps: false)
      end
    end
  end
end
