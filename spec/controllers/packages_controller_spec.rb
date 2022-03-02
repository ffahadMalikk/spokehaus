require 'rails_helper'

RSpec.describe PackagesController, type: :controller do

  context "#buy" do

    it "only allows authenticated users to make purchases" do
      post :buy
      expect(response).to redirect_to(new_user_session_url)
    end

    it "renders index for invalid purchases" do
      sign_in_as_registered_user

      post :buy, purchase: { package_id: 123 }

      expect(response).to render_template(:index)
      expect(assigns(:purchase)).to_not be_valid
    end

    it "renders an error when the purchase fails" do
      sign_in_as_registered_user
      api = stub_api
      expect(api).to receive(:purchase).and_raise(failed_avs_check)

      post :buy, purchase: purchase_params

      expect(flash[:error]).to eq FAILED_AVS_CHECK
      expect(response).to render_template(:index)
    end

    it "redirects to complete_pending_bookings_url if there is a pending booking" do
      user = sign_in_as_registered_user

      api = stub_api
      allow(api).to receive(:purchase)

      create(:booking, user: user, status: :pending_credits)

      post :buy, purchase: purchase_params

      expect(response).to redirect_to complete_pending_bookings_url
    end

    it "confirms credits purchased" do
      sign_in_as_registered_user
      api = stub_api
      allow(api).to receive(:purchase)

      post :buy, purchase: purchase_params

      expect(response).to render_template(:confirm)
    end

  end

  private

  def sign_in_as_registered_user
    user = create(:registered_user, cc_last_four: 1234, cc_expiry: Date.new(2020, 1, 1))
    sign_in(user)
    user
  end

  def purchase_params
    {
      package_id: create(:package).id,
      payment_type: 'stored_card'
    }
  end

  def credit_card_purchase_params
    {
      package_id: create(:package).id,
      payment_type: 'new_card',
      name_on_card: 'Oliver Twist',
      card_number: '1234 1234 1234 4321',
      address: '123 Example St.',
      city: 'Toronto',
      province: 'ON',
      postal_code: 'M4L 2V5',
      expiry_month: '01',
      expiry_year: '2020',
      save_card: true,
    }
  end

  def stub_api
    instance_double(MindBodyApi).tap do |api|
      controller.api = api
    end
  end

  FAILED_AVS_CHECK = "Card Authorization Failed Your request has failed the AVS check. Note that the amount has still been reserved on the customer's card and will be released in 3-5 business days. Please ensure the billing address is accurate before retrying the transaction."

  def failed_avs_check
    result = double('api-result', status: 'InvalidParameters', error_code: '9999', error_message: FAILED_AVS_CHECK)

    MindBody::ApiError.new(result)
  end

  def failed_to_store_card_error
    result = double('api-result', status: 'InvalidParameters', error_code: '9999', error_message: "Failure")
    MindBody::ApiError.new(result)
  end

end
