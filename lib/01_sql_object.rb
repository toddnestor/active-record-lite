require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= self.get_columns
  end

  def self.get_columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT 1
    SQL

    data.first.map {|col| col.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.build_select(attrs = nil)
    attrs ||= ['*']
    sql = <<-SQL
      SELECT
        #{attrs.join(', ')}
    SQL
    sql
  end

  def self.build_joins(joins = [])
    join_strings = []

    joins.each do |join|
      if join[:table] && join[:on]
        join_strings << <<-SQL
          #{join[:type] ? join[:type].upcase : 'JOIN'} #{join[:table]} ON #{join[:on]}
        SQL
      end
    end

    join_strings.join("\n")
  end

  def self.build_from(table = self.table_name, joins = [])
    sql = <<-SQL
      FROM
        #{table}
        #{self.build_joins(joins)}
    SQL

    sql
  end

  def self.build_where_clauses(wheres)
    wheres = [wheres] unless wheres.is_a?(Array)

    where_strings = []

    wheres.each_with_index do |where, i|
      where_string = ""

      where[:type] ||= 'AND'
      where[:comparator] ||= '='

      where_string += i > 0 ? "#{where[:type]} }" : ""

      if where.is_a?(Array)
        where_string += self.build_where(where)
      else
        where_string += "#{where[:col]} #{where[:comparator]} #{where[:value]}"
      end

      where_strings << where_string
    end

    where_strings.join("\n")
  end

  def self.build_where(wheres)
    "WHERE #{self.build_where_clauses(wheres)}"
  end

  def self.all
    sql = self.build_select + self.build_from
    self.parse_all(DBConnection.execute(sql))
  end

  def self.execute(sql)
    DBConnection.execute(sql)
  end

  def self.get_objects(sql)
    self.parse_all(self.execute(sql))
  end

  def self.parse_all(results)
    results.map {|el| self.new(el)}
  end

  def self.find(id)
    sql = self.build_select + self.build_from + self.build_where(col: :id, value: id)
    self.get_objects(sql).first
  end

  def initialize(params = {})
    params.each do |key, val|
      name = key.to_sym
      raise "unknown attribute '#{name}'" unless self.class.columns.include?(name)
      self.send("#{name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
