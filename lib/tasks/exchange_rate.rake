namespace :exchange_rate do
  desc 'insert day zero countries'
  task day_zero_history: %w[environment] do
    ExchangeRates::CountryHistories::CreateDayZero.call('data/exchange_rates/day_zero_country_history.csv')
  end
end
