require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
    )

  def model_class
    @name.camelcase.singularize.constantize
  end

  def table_name
    model_class.table_name ||= @name.underscore.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    self.foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name

    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    _options = BelongsToOptions.new(name.to_s, options)
    assoc_options[name] = _options

    define_method(name) do
      _options.model_class.where(:id => send(_options.foreign_key)).first
    end
  end

  def has_many(name, options = {})
    _options = HasManyOptions.new(name.to_s, self.to_s, options)

    define_method(name.to_s.pluralize.to_sym) do
      _options.model_class.where(_options.foreign_key => self.id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
