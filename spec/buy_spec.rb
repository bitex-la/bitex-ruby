require 'spec_helper'

describe Bitex::Buy do
  let(:as_json) do
    [4,12345678,946685400,1,100.50000000,201.0000000,0.05000000,2.00000000]
  end
  
  it_behaves_like 'API class'
  it_behaves_like 'API class with a specie'
  it_behaves_like 'JSON deserializable match'
end
