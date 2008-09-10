# DumpMysqlTriggers
require "active_record/connection_adapters/mysql_adapter"

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def structure_dump_with_triggers
        triggers = select_all("SHOW TRIGGERS").inject([]) do |list, trigger_hash|
          list <<
            "CREATE TRIGGER #{trigger_hash["Trigger"]} "+
            "#{trigger_hash["Timing"]} #{trigger_hash["Event"]} " +
            "ON #{trigger_hash["Table"]} " +
            "FOR EACH ROW "+
              "#{trigger_hash["Statement"]};\n\n"
        end
        structure_dump_without_triggers + triggers.join("\n")
      end
      alias_method_chain :structure_dump, :triggers
    end
  end
end
