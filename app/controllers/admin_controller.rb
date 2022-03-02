class AdminController < ApplicationController
  before_action :authenticate_admin!

  def sign_up_sheet
    query = SignUpsQuery.new(params.fetch(:id))
    @sign_ups = ScheduledClass::SignUpsPresenter.new(query)
  end

  private

  def authenticate_admin!
    authenticate_user!
    unless current_user.admin?
      flash[:error] = "You don't have permission to access this resource"
      redirect_to '/'
    end
  end

end
