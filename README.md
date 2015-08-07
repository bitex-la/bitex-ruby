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

Bitex::BitcoinMarketData has methods for
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

## Exchange Rates 

Learn more here: [https://sandbox.bitex.la/developers#rates](Rates docs)


From 1000 ARS in CASH to USD in my BITEX balance, via MORE_MT

    ruby > Bitex::Rates.calculate_path(1000, [:ars, :cash, :usd, :bitex, :more_mt])

How many ARS in CASH should I deposit via MORE_MT to get 50 USD in BITEX?

    ruby > Bitex::Rates.calculate_path_backwards([:ars, :cash, :usd, :bitex, :more_mt], 50)

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

    ruby > Bitex::Ask.create!(:btc, 2, 500) # Try to sell 2 Btc at $500 each.

### List your pending or recently active orders

    ruby > Bitex::Order.all

### List your recent transactions

    ruby > Bitex::Transaction.all

# Payments

Check the [https://sandbox.bitex.la/developers#payments-overview](Payaments Developer Docs)
to learn more about payment processing with Bitex

### Create a new payment for 4 USD in Bitcoin

    ruby > Bitex::Payment.create!(
      currency_id: 3,
      amount: 4,
      callback_url: "https://example.com/ipn",
      keep: 25.0,
      customer_reference: "An Alto latte, no sugar",
      merchant_reference: "invoice#1234")

### List all your payments

    ruby > Bitex::Payment.all

### Validate and deserialize payments from callbacks.

    ruby > Bitex::Payment.from_callback(the_callback_json)

###  Setup your Web Point of Sale
  
    ruby > Bitex::Payment.pos_setup!(
      merchant_name: "Tierra Buena",
      merchant_slug: "tierrabuena",
      merchant_logo: "https://t.co/logo.png",
      merchant_keep: 0)

## Sandbox

Bitex.la has a sandbox environment available at https://sandbox.bitex.la, you
can signup and create api keys there, and try this library on the sandbox
enviornment by doing

    ruby > Bitex.sandbox = true

## Want more?

Find the full API description at
[https://bitex.la/developers](https://bitex.la/developers)

Read this gems full documentation at
[http://rubydoc.info/github/bitex-la/bitex-ruby/master/frames/file/README.md](http://rubydoc.info/github/bitex-la/bitex-ruby/master/frames/file/README.md)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
