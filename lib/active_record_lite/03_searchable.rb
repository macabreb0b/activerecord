require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    _columns = []
    _where_filters = []
    params.each do |key, value|
      _columns << value.to_s
      _where_filters << "#{key} = ?"
    end

    puts _columns
    puts _where_filters

    self.parse_all(DBConnection.execute(<<-SQL, _columns))
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{_where_filters.join(" AND ")}
    SQL
  end
end

class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
