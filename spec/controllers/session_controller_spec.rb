require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  scenario 'logging in makes a call to the MindBody API for details' do
    # Given an existing user is signing ing
    user = create(:user)

    # and we have her shoe size in mindbody
    api = instance_double(MindBodyApi, get_shoe_size: "10.5")
    allow(MindBodyApi).to receive(:new).and_return(api)

    # and she signs in
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, user: {email: user.email, password: user.password}

    # expect her shoe size to be set on the current_user
    expect(subject.current_or_guest_user.shoe_size).to eq 10.5

    # and that her local record was updated
    expect(user.reload.shoe_size).to eq 10.5
  end

end
