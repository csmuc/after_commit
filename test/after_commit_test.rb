$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rubygems'
require 'activerecord'

ActiveRecord::Base.establish_connection({"adapter" => defined?(JRUBY_VERSION) ? "jdbcsqlite3":"sqlite3", "database" => 'test.sqlite3'})
begin
  ActiveRecord::Base.connection.execute("drop table mock_records");
rescue
end
ActiveRecord::Base.connection.execute("create table mock_records(id int)");

require File.dirname(__FILE__) + '/../init.rb'

class MockRecord < ActiveRecord::Base
  include AfterCommit::ActiveRecord
  attr_accessor :after_commit_on_create_called, :after_commit_on_update_called, :after_commit_on_destroy_called

  def after_commit_on_create
    self.after_commit_on_create_called = true
  end

  def after_commit_on_update
    self.after_commit_on_update_called = true
  end

  def after_commit_on_destroy
    self.after_commit_on_destroy_called = true
  end
end

class AfterCommitTest < Test::Unit::TestCase
  def test_after_commit_on_create_is_called
    assert_equal true, MockRecord.create!.after_commit_on_create_called
  end

  def test_after_commit_on_update_is_called
    record = MockRecord.create!
    record.save
    assert_equal true, record.after_commit_on_update_called
  end

  def test_after_commit_on_destroy_is_called
    assert_equal true, MockRecord.create!.destroy.after_commit_on_destroy_called
  end
end
