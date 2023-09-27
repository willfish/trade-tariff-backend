require 'csv'

class ExchangeRateCountryHistory < Sequel::Model
  dataset_module do
    def active
      today = Time.zone.today.beginning_of_day

      filter(end_date: nil) || filter('start_date >= ?', today).filter('end_date <= ?', today)
    end

    def active_currency_codes
      active.pluck(:currency_code)
    end
  end
end
