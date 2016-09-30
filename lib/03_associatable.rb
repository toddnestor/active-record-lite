require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    Kernel.const_get(self.class_name)
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  attr_accessor :foreign_key, :primary_key, :class_name

  def initialize(name, options = {})
    default_options = {
      primary_key: :id,
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }

    options = default_options.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  attr_accessor :foreign_key, :primary_key, :class_name

  def initialize(name, self_class_name, options = {})
    default_options = {
      primary_key: :id,
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }

    options = default_options.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    belongs_to_options = BelongsToOptions.new(name, options)

    define_method(name) do
      belongs_to_options
        .model_class
        .where(belongs_to_options.primary_key => self.send(belongs_to_options.foreign_key))
        .first
    end
  end

  def has_many(name, options = {})
    has_many_options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      has_many_options
        .model_class
        .where(has_many_options.foreign_key => self.send(has_many_options.primary_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
