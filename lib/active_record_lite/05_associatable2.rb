require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      source_class = source_options.model_class
      belongs_to_id = self.send(through_name).id

      source_class.parse_all(DBConnection.execute(<<-SQL, belongs_to_id)
        SELECT
          source.*
        FROM
          #{through_options.table_name} through
        JOIN
          #{source_options.table_name} source
        ON
          source.#{source_options.primary_key} = through.#{source_options.foreign_key}
        WHERE
          through.#{through_options.primary_key} = ?
      SQL
      ).first
    end
  end
end
