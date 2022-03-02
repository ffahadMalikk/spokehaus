require 'rails_helper'

RSpec.describe Bike, type: :model do

  it 'requires a position to be valid' do
    expect(build(:bike, position: nil)).to_not be_valid
  end

end
