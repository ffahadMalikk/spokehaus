require 'rails_helper'

RSpec.describe AdminController, type: :controller do

  it 'allows access to admin users' do
    sign_in create(:admin)
    get :sign_up_sheet, id: create(:scheduled_class)
  end

  it 'disallows access to guest user' do
    get :sign_up_sheet, id: create(:scheduled_class)
    expect(response).to redirect_to('/users/sign_in')
  end

  it 'disallows access to registered users' do
    sign_in create(:registered_user)
    get :sign_up_sheet, id: create(:scheduled_class)
    expect(response).to redirect_to('/')
  end

end
