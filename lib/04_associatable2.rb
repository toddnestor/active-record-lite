require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_class = through_options.model_class
      through_table = through_class.table_name

      source_class = source_options.model_class
      source_table = source_class.table_name

      joins = []
      joins << {table: source_table, on: "#{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}"}

      sql = source_options.model_class.build_select("#{source_table}.*") + through_class.build_from(joins)
      sql += through_class.build_where(col: "#{through_table}.#{through_options.primary_key}", value: "?")

      source_class.get_objects(sql, self.send(through_name).id).first
    end
  end
end
