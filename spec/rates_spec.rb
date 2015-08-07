require 'spec_helper'

describe Bitex::Rates do
  before(:each){ Bitex::Rates.clear_tree_cache }

  it "gets the full exchange rates tree and caches for 1 minute" do
    Bitex::Rates.clear_tree_cache
    Bitex.api_key = 'valid_api_key'
    stub = stub_get("/rates/tree", 'rates_tree')
    Bitex::Rates.tree.keys.should == 
      %w(btc usd ars clp eur uyu brl cop pen mxn bob nio hnl dop gbp cad vef).collect(&:to_sym)
    2.times{ Bitex::Rates.tree }
    Timecop.travel 2.minutes.from_now
    Bitex::Rates.tree
    stub.should have_been_requested.twice
  end
  
  it "calculates a given path using the tree" do
    stub_get("/rates/tree", 'rates_tree')
    Bitex::Rates.calculate_path(1000, [:ars, :cash, :usd, :bitex, :more_mt])
      .should == '64.332439179'.to_d
  end
  
  it "calculates backwards using a path" do
    stub_get("/rates/tree", 'rates_tree')
    Bitex::Rates.calculate_path_backwards([:ars, :cash, :usd, :bitex, :more_mt], 64)
      .should == '994.832479799730206496'.to_d
  end
end
