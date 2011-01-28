require 'cucumber/thinking_sphinx/external_world'
Cucumber::ThinkingSphinx::ExternalWorld.new

# This monkey-patch is required to use ThinkingSphinx with "foxy
# fixtures" and PostgreSQL. Foxy fixtures are given random integer
# IDs, which can be quite large. ThinkingSphinx multiplies these
# IDs by another (small) integer to get a Sphinx record ID, in
# order to ensure IDs are unique across all tables. The resulting
# Sphinx ID may be too large for a 32-bit integer, and PostgreSQL
# generates an error when building the index. To solve the problem,
# we cast the ID as a BIGINT.
module ThinkingSphinx
  class Source
    module SQL
      def sql_select_clause(offset)
        unique_id_expr = ThinkingSphinx.unique_id_expression(offset)

        (
          ["CAST(#{@model.quoted_table_name}.#{quote_column(@model.primary_key_for_sphinx)} AS BIGINT) #{unique_id_expr} AS #{quote_column(@model.primary_key_for_sphinx)} "] +
          @fields.collect     { |field|     field.to_select_sql     } +
          @attributes.collect { |attribute| attribute.to_select_sql }
        ).compact.join(", ")
      end
    end
  end
end
