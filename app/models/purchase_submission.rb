class PurchaseSubmission

  def initialize(user, api, form)
    @user = user
    @api = api
    @form = form
  end

  def process
    if @form.valid?
      send_purchase.tap do |result|
        if result.ok?
          store_card
          apply_friend_credits
        end
      end
    else
      PurchaseResult.invalid(@form)
    end
  end

  private

  def send_purchase
    package = @form.package
    payment = create_payment(package)
    @api.purchase(@user.id, item: package, payment: payment)
    PurchaseResult.ok(package)
  rescue MindBody::ApiError => e
    Rails.logger.error(e)
    Honeybadger.notify(e)
    PurchaseResult.error(e)
  end

  def store_card
    if @form.should_save_card?
      StoreCreditCardJob.store(@form.credit_card, for_user: @user)
    end
  end

  def apply_friend_credits
    @user.increment!(:friend_credits, @form.package.friend_credits)
  end

  def create_payment(package)
    total = package.total
    case
    when comped?
      Payments::Comped.new(total)
    when @form.new_card?
      Payments::CreditCard.new(total, @form.credit_card)
    when @form.stored_card?
      Payments::StoredCreditCard.new(total, @user.stored_card)
    else
      raise "invalid payment"
    end
  end

  def comped?
    comped = Rails.env.staging? || Rails.env.development?
    Rails.logger.warn('Comped payment.') if comped
    comped
  end

end
