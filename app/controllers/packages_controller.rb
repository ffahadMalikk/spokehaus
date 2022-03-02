class PackagesController < ApplicationController

  def index
    @packages = load_packages
    @purchase = build_purchase
  end

  def buy
    authenticate_user!

    @packages = load_packages
    @purchase = build_purchase(purchase_params)

    submission = PurchaseSubmission.new(current_or_guest_user, api, @purchase)
    begin
      result = submission.process
      case result.status
      when :ok
        if has_pending_booking?
          redirect_to complete_pending_bookings_url
        else
          @credits_purchased = result.credits_purchased
          render :confirm
        end
      when :invalid
        render :index
      when :error
        flash[:error] = result.error_message
        render :index
      end
    rescue MindBody::CheckoutError => e
      flash[:error] = if e.message =~ /Card Authorization Failed/
        I18n.t('packages.authorization_failed')
      elsif e.message =~ /The input cart items are invalid/
        Honeybadger.notify(e)
        I18n.t('packages.unexpected_error')
      else
        raise e
      end
      render :index
    end
  end

  private

  def has_pending_booking?
    Booking.pending_credits.for(current_user).any?
  end

  def load_packages
    packages = Package
      .visible
      .order(friend_credits: :desc, price_in_cents: :asc, count: :asc)
      .to_a
    unlimiteds = packages.select(&:is_unlimited?)
    packages = packages.reject!(&:is_unlimited?).unshift(unlimiteds).flatten
    packages
  end

  def build_purchase(params = {})
    Purchase.new(params.merge(stored_card: current_or_guest_user.stored_card))
  end

  def purchase_params
    params.require(:purchase).permit(
      :package_id,
      :payment_type,
      :name_on_card,
      :card_number,
      :address,
      :city,
      :province,
      :postal_code,
      :expiry_year,
      :expiry_month,
      :save_card,
    )
  end

end
