require 'spec_helper'

describe Bitex::Rates do
  it "gets all rates" do
    Bitex.api_key = 'valid_api_key'
    stub_private(:get, "/private/rates", 'rates')
    Bitex::Rates.all.should == {
      AR: {
        astropay: {USDARS: [8.7592,nil,1412969688]}, 
        reference:{USDARS: [nil,nil,0]}},
      BR: {astropay:{USDBRL: [2.3779,nil,1412969689]}},
      CL: {astropay:{USDCLP: [611.673,nil,1412969691]}},
      CO: {astropay:{USDCOP: [2006.368,nil,1412969693]}},
      PE: {astropay:{USDPEN: [2.9807,nil,1412969696]}},
      UY: {astropay:{USDUYU: [24.751,nil,1412969698]}},
      MX: {astropay:{USDMXN: [13.7471,nil,1412969700]}}
   }
  end
end
