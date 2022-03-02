class CompFirstRide

  def initialize(user, guest_booking, api = MindBodyApi.new)
    @user = user
    @api = api
    @guest_booking = guest_booking
  end

  def apply
    package = Package.one_ride
    payment = Payments::Comped.new(package.total)

    buy_package(package, payment).tap do
      complete_guest_booking
    end
  end

  private

  def buy_package(package, payment)
    @api.purchase(@user.id, item: package, payment: payment)
  end

  def complete_guest_booking
    if can_complete_booking?
      pending_booking = PendingBooking.new(@guest_booking, @api)
      pending_booking.complete
    end
  end

  def can_complete_booking?
    @guest_booking.present? &&
      @api.get_remaining_credits(@user.id) >= @guest_booking.cost_in_credits
  end

end
