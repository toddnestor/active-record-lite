require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    sql = build_select + build_from

    wheres = []

    params.each do |key, val|
      wheres << {col: key, value: '?'}
    end

    sql += self.build_where(wheres)

    get_objects(sql, params.values)
  end
end

class SQLObject
  extend Searchable
end
