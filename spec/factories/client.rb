FactoryBot.define do
  factory :client, class: Bitex::Client do
    api_key     Faker::Lorem.characters(30)
    sandbox     false
    debug       false
    ssl_version nil
  end
end
