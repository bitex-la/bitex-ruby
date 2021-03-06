require 'spec_helper'

describe Bitex::MarketData do
  { btc: Bitex::BitcoinMarketData, bch: Bitex::BitcoinCashMarketData }.each do |crypto_currency, market|
    it "gets the ticker" do
      stub_get("/#{crypto_currency}/market/ticker", 'market_ticker')
      market.ticker.should == {
        last: 639.0, high: 659.0, low: 639.0, vwap: 647.195852839369,
        volume: 4.80579022, bid: 637.0, ask: 638.5
      }
    end

    it "gets the order book" do
      stub_get("/#{crypto_currency}/market/order_book", 'order_book')
      market.order_book.should == {
        bids: [[639.21,1.95],[637.0,0.47],[630.0,1.58]],
        asks: [[642.4,0.4],[643.3,0.95],[644.3,0.25]]
      }
    end

    it "gets the transactions" do
      stub_get("/#{crypto_currency}/market/transactions", 'transactions')
      market.transactions.should == [
        [1404259180, 1272, 650.0, 0.5],
        [1404259179, 1271, 639.0, 0.46948356]
      ]
    end

    %w(last_24_hours last_7_days last_30_days).each do |method|
      it "gets aggregated data for #{method}" do
        stub_get("/#{crypto_currency}/market/#{method}", 'aggregated_data')
        market.send(method).should == [
          [1403668800, 570.0, 574.0, 570.0, 574.0, 1.06771929, 571.0, 570.917848641659],
          [1403683200, 560.0, 570.0, 560.0, 570.0, 1.14175147, 565.0, 565.753596095655],
          [1403697600, 560.0, 560.0, 560.0, 560.0, 0.0, 565.0, 0.0],
          [1403712000, 560.0, 560.0, 560.0, 560.0, 0.0, 565.0, 0.0]
        ]
      end
    end
  end
end
