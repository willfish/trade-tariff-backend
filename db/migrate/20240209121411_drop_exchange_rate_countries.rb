# frozen_string_literal: true

Sequel.migration do
  up do
    drop_table :exchange_rate_countries
  end

  down do
    create_table :exchange_rate_countries do
    end
  end
end
