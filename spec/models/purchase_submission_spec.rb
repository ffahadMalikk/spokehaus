require 'rails_helper'

RSpec.describe PurchaseSubmission, type: :model do

  scenario 'It applies friend credits when buying' do
    package = create(:package, friend_credits: 1)
    user = create(:registered_user, cc_expiry: Date.new(2018, 6), cc_last_four: '1234')

    api = MindBodyApi.new
    form = create_form(user, package)
    submission = PurchaseSubmission.new(user, api, form)
    result = submission.process

    expect(result).to be_ok
    expect(user.reload.friend_credits).to eq(1)
  end

  private

  def create_form(user, package)
    form = Purchase.new(
      stored_card: user.stored_card,
      package_id: package.id,
      payment_type: 'stored_card',
    )
    expect(form).to be_valid
    form
  end


end
