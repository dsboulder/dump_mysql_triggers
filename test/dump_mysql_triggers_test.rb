require 'test/unit'
require "rubygems"
require "activesupport"
require "activerecord"
require 'mocha'
require File.dirname(__FILE__) + "/../lib/dump_mysql_triggers"

class DumpMysqlTriggersTest < Test::Unit::TestCase
  def test_trigger_dumping
    ActiveRecord::ConnectionAdapters::MysqlAdapter.any_instance.stubs(:connect)
    conn = ActiveRecord::ConnectionAdapters::MysqlAdapter.new(nil, nil, nil, nil)
    conn.expects(:select_all).returns([
      {"Trigger" => "trigger1", "Table" => "table1", "Event" => "INSERT", "Timing" => "BEFORE", "Statement" => "SELECT RAND()"}
    ])
    conn.expects(:structure_dump_without_triggers).returns("old_stuff\n")
    dump = conn.structure_dump
    expected_output = "CREATE TRIGGER trigger1 BEFORE INSERT ON table1 FOR EACH ROW SELECT RAND();"
    assert dump.include?(expected_output), "Expected '#{dump}' to contain #{expected_output}"
    assert dump.include?("old_stuff"), "Expected '#{dump}' to contain 'old stuff'"
  end
end
