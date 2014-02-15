require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    objects = []
    results.each do |result|
      object = self.new(result)
      objects << object
    end
    objects
  end
end

class SQLObject < MassObject
  def self.columns
    @columns ||= DBConnection.execute2("SELECT * FROM #{@table_name}")
      .first.to_a.map do |attribute|
        getter = attribute.to_sym
        setter = "#{attribute}=".to_sym

        define_method(getter) do
          self.attributes[getter]
        end

        define_method(setter) do |val|
          self.attributes[getter] = val
        end

        getter
      end
    @columns
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    class_name = self.to_s.underscore.downcase.pluralize
    @table_name ||= class_name
  end

  def self.all
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name}"))
  end

  def self.find(id)
    # p self.table_name
    self.new(DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = ? LIMIT 1", id).first)
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    q_marks = self.attributes.keys.map{"?"}.join(', ')

    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{self.attributes.keys.join(", ")})
      VALUES
        (#{q_marks});
      SQL

    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=".to_sym, value)
    end
  end

  def save
    attributes[:id].nil? ? self.insert : self.update
  end

  def update
    _updates = []
    _attributes = []
    self.attributes.keys.select { |attribute| attribute != :id }
      .map do |attribute|
        _updates << "#{attribute} = ?"
        _attributes << attributes[attribute]
    end

    DBConnection.execute(<<-SQL, *_attributes)
      UPDATE
        #{self.class.table_name}
      SET
        #{_updates.join(", ")}
      WHERE
       id = #{self.id};
    SQL

  end

  def attribute_values
    attributes.values
  end
end
