require 'rails_helper'

RSpec.describe User, type: :model do

  it 'parses first_name from a name' do
    user = build(:user, name: 'first last')
    expect(user.first_name).to eq 'first'
  end

end
