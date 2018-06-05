require 'spec_helper'

describe Bitex::Client do
  context 'defining' do
    subject { described_class.new }

    it 'attr accessors' do
      should respond_to(:api_key)
      should respond_to(:debug)
      should respond_to(:sandbox)
      should respond_to(:ssl_version)
    end

    context 'attr reader' do
      { Order: :orders }.each do |kind, attr|
        it "bind with his #{kind} Bitex Api Reference" do
          should respond_to(attr)
          subject.send(attr).tap do |kind_struct|
            kind_struct.should be_a(Struct)
            kind_struct.should be_a("Bitex::Client::#{kind}".constantize)
            kind_struct.send(:kind).should eq("Bitex::#{kind}".constantize)
          end
        end
      end
    end
  end

  context 'calling' do
    let(:client) { Bitex::Client.new(api_key: 'valid_api_key') }

    it 'has all attr accessors' do
      stub_private(:get, '/private/orders', 'orders')

      client.orders.all
    end
  end
end
