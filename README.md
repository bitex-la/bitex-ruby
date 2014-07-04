# Bitex

[Bitex.la](https://bitex.la/developers) API Client library.


## Installation

Add this line to your application's Gemfile:

    gem 'bitex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitex


## Use Public Market Data

Bitex::BitcoinMarketData and Bitex::LitecoinMarketData classes have methods for
fetching all public market data available.

### Ticker

    ruby > Bitex::BitcoinMarketData.ticker
    => {:last=>632.0, :high=>648.0, :low=>625.94, :vwap=>633.670289779918,
        :volume=>9.49595029, :bid=>632.0, :ask=>648.0}

### Order Book

    ruby > Bitex::BitcoinMarketData.order_book
    => {:bids=>[[632.0, 38.910443037975], [630.87, 1.8], ...],
        :asks=>[[634.9, 0.95], [648.0, 0.4809267], ...]}

### Transactions

    ruby > Bitex::BitcoinMarketData.transactions
    => [[1404501180, 1335, 632.0, 0.95], [1404501159, 1334, 632.0, 0.95], ...]

## Use for Private Trading

### Authentication

Sign in to [https://bitex.la/developers](https://bitex.la/developers) and create
an `api_key`. You can find more information about our authentication security
on that page. Once done you can start using it as follows:

    ruby > Bitex.api_key = 'your_api_key'
    => "your_api_key"

### Get your balances, deposit addresses, fee

    ruby > Bitex::Profile.get

### Place a Bid

    ruby > Bitex::Bid.create!(:btc, 1000, 500) # Spend 1000 USD in btc, paying up to 500 each

### Place an Ask

    ruby > Bitex::Ask.create!(:ltc, 2, 500) # Sell 2 LTC

### List your pending or recently active orders

    ruby > Bitex::Order.all

### List your recent transactions

    ruby > Bitex::Transaction.all


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
