require 'rails_helper'

RSpec.describe DatabaseHelper do
  describe "failover_on" do
    let(:fake_connection) { double('ActiveRecord::Connection', stick_to_master!: true)}

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(fake_connection)
    end

    it 'should not failover to master if failover test fails' do
      expect(ActiveRecord::Base.connection).to receive(:stick_to_master!).never
      DatabaseHelper.failover_on(:blank?) do
        true
      end
    end

    it 'should unstick from master after sticking to master' do
      new_context = 'new_context'
      expect(ActiveRecord::Base.connection).to receive(:stick_to_master!).once
      expect(Makara::Context).to receive(:generate).once.and_return(new_context)
      expect(Makara::Context).to receive(:set_current).once.with(new_context)
      DatabaseHelper.failover_on(:blank?) do
        nil
      end
    end
  end

end
