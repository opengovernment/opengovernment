module ActiveRecord
  class Base
    # Given a column name and an array of values, this acts as a scope
    # and ensures sure that the rows are returned in exactly the order
    # of the values given.

    # This is PostgreSQL-specific; in MySQL you would use fields()
    def self.find_in_explicit_order(column_name, values)
      order_clause = 'CASE '
      values.each_with_index do |id, i|
        order_clause += "WHEN #{column_name} = #{id} THEN #{i} "
      end
      order_clause += ' END'

      scoped.order(order_clause).where(column_name => values)
    end
  end
end