shared_examples_for 'Order' do |api_path|
  it 'lists all' do
    stub_private(:get, '/private/orders', 'orders')
    order, empty = subject.class.all
    order.should be_a subject.class
    empty.should be_nil
  end

  it 'gets one' do
    stub_private(:get, "/private/#{api_path}/12345678", "#{api_path}_show")
    order = subject.class.find(12_345_678)
    order.should be_a subject.class
    order.id.should == 12_345_678
  end

  it 'places for btc_usd' do
    stub_private(:post, "/private/#{api_path}", "#{api_path}_create", { amount: 100.50, price: 1000.00, orderbook: 1 })
    order = subject.class.create!(:btc_usd, 100.50, 1_000.00)
    order.should be_a subject.class
    order.status.should == :received
  end

  it 'places for btc_usd and waits until processed by our matching engine' do
    stub_private(:post, "/private/#{api_path}", "#{api_path}_create", { amount: 100.50, price: 1_000.00, orderbook: 1})
    stub_private(:get, "/private/#{api_path}/12345678", "#{api_path}_show")
    order = subject.class.create!(:btc_usd, 100.50, 1_000.00, true)
    order.should be_a subject.class
    order.status.should == :executing
  end

  it 'cancels one' do
    stub_private(:post, "/private/#{api_path}", "#{api_path}_create", { amount: 100.50, price: 1_000.00, orderbook: 1})
    order = subject.class.create!(:btc_usd, 100.50, 1_000.00)
    stub_private(:post, "/private/#{api_path}/#{order.id}/cancel", "#{api_path}_cancel")
    order.cancel!
    order.status.should == :cancelling
  end

  it 'blows up when unknown order book is requested' do
    expect do
      subject.class.create!(:bogus_order_book, 100.50, 1_000.00)
    end.to raise_error Bitex::UnknownOrderBook
  end
end
