# frozen_string_literal: true

Sequel.migration do
  up do
    raise 'This will fail'
  end

  down do
    # do nothing
  end
end
