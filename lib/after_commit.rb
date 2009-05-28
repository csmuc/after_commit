module AfterCommit  
  def self.touched_records(type)
    h = (Thread.current[:after_commit] ||= {})
    h[type] ||= []
  end
  
  def self.clear
    Thread.current[:after_commit] = nil
  end

  def self.trigger
    begin
      [:create, :update, :destroy].each do |type|
        callback_name = "after_commit_on_#{type}"
        touched_records(type).each do |record|
          begin
            record.send(callback_name) if record.respond_to?(callback_name)
          rescue => e
            puts e
          end
        end
      end
    ensure
      self.clear
    end
  end
  
  module ActiveRecord
    def self.included(base)
      base.class_eval do
        after_create  :add_touched_record_on_create
        after_update  :add_touched_record_on_update
        after_destroy :add_touched_record_on_destroy

        def add_touched_record_on_create
          AfterCommit.touched_records(:create) << self
        end
        
        def add_touched_record_on_update
          AfterCommit.touched_records(:update) << self
        end
        
        def add_touched_record_on_destroy
          AfterCommit.touched_records(:destroy) << self
        end        
      end
    end
  end
  
  module ConnectionAdapters
    def self.included(base)
      base.class_eval do
        # The commit_db_transaction method gets called when the outermost
        # transaction finishes and everything inside commits. We want to
        # override it so that after this happens, any records that were saved
        # or destroyed within this transaction now get their after_commit
        # callback fired.
        def commit_db_transaction_with_callback
          commit_db_transaction_without_callback
          AfterCommit.trigger
        end
        alias_method_chain :commit_db_transaction, :callback
        
        def rollback_db_transaction_with_callback
          rollback_db_transaction_without_callback
          AfterCommit.clear
        end
        alias_method_chain :rollback_db_transaction, :callback
      end
    end
  end
end

unless defined? AFTER_COMMIT_PATCH_APPLIED
  AFTER_COMMIT_PATCH_APPLIED=true   # in my test setup this was executed twice resulting in an infinite recursion  
  
  Object.subclasses_of(ActiveRecord::ConnectionAdapters::AbstractAdapter).each do |klass|
    puts "Applying after_commit patch to: #{klass}"
    klass.send(:include, AfterCommit::ConnectionAdapters)
  end

  if defined?(JRUBY_VERSION) and defined?(JdbcSpec::MySQL)
    JdbcSpec::MySQL.send :include, AfterCommit::ConnectionAdapters
  end  
end