require 'rails_helper'

RSpec.describe Package, type: :model do

  it 'rounds to the nearest penny' do
    hst = 0.13
    [
      [    0,   0.00],
      [ 2478,  28.00],
      [11504, 130.00],
      [21239, 240.00],
      [38938, 440.00],
    ].each do |price_in_cents, expected_amount|
      package = create(:package, tax_rate: hst, price_in_cents: price_in_cents)
      expect(package.total).to eq expected_amount
    end
  end

end
