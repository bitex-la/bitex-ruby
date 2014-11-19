shared_examples_for 'API class' do
  it 'stores the unique id' do
    as_json[1] = 12345678
    subject.class.from_json(as_json).id.should == 12345678
  end

  it 'makes creation times into Time' do
    subject.class.from_json(as_json).created_at.should be_a Time
  end
end

shared_examples_for 'API class with a specie' do
  it 'makes specie 1 into btc' do
    as_json[3] = 1
    subject.class.from_json(as_json).specie.should == :btc
  end

  it 'makes specie 2 into ltc' do
    as_json[3] = 2
    subject.class.from_json(as_json).specie.should == :ltc
  end
end

shared_examples_for 'JSON deserializable match' do
  { quantity: 100.5, amount: 201, fee: 0.05, price: 2.0 }.each do |field, value|
    it "sets #{field} as BigDecimal" do
      thing = subject.class.from_json(as_json).send(field)
      thing.should be_a BigDecimal
      thing.should == value
    end
  end
end

shared_examples_for 'JSON deserializable order' do
  it "sets price as BigDecimal" do
    thing = subject.class.from_json(as_json).price
    thing.should be_a BigDecimal
    thing.should == 1000.0
  end
  
  { 1 => :received,
    2 => :executing,
    3 => :cancelling,
    4 => :cancelled,
    5 => :completed,
  }.each do |code, symbol|
    it "sets status #{code} to #{symbol}" do
      as_json[7] = code
      subject.class.from_json(as_json).status.should == symbol
    end
  end

  { 0 => :not_cancelled,
    1 => :not_enough_funds,
    2 => :user_cancelled,
    3 => :system_cancelled,
  }.each do |code, symbol|
    it "sets reason #{code} to #{symbol}" do
      as_json[8] = code
      subject.class.from_json(as_json).reason.should == symbol
    end
  end
  
  it 'sets the issuer' do
    as_json[10] = 'User#22'
    subject.class.from_json(as_json).issuer.should == 'User#22'
  end
end
