class DatabaseHelper

  def self.failover_on(test_method, &block)
    result = block.call
    if result.send(test_method)
      DatabaseHelper.force_master!
      result = block.call
      DatabaseHelper.unforce_master!
    end
    result
  end

  protected

  def self.force_master!
    ActiveRecord::Base.connection.stick_to_master! if ActiveRecord::Base.connection.respond_to?(:stick_to_master!)
  end

  def self.unforce_master!
    Makara::Context.set_current(Makara::Context.generate)
  end
end
