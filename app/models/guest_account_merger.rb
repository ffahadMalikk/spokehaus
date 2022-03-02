class GuestAccountMerger

  def self.merge(guest, registered)
    new(guest, registered).merge(guest.bookings)
  end

  def self.merge_pending_bookings(guest, registered)
    new(guest, registered).merge(guest.bookings.guest)
  end

  def initialize(source, destination)
    @source = source
    @destination = destination
  end

  def merge(booking_scope)
    booking_scope.each do |guest_booking|
      begin
        if Flags.comp_first_ride?
          guest_booking.update(user_id: @destination.id)
        else
          guest_booking.update(
            user_id: @destination.id,
            status: :pending_credits
          )
        end
      rescue => e
        Rails.logger.error("failed to merge guest booking, #{e}")
      end
      if guest = @source.reload
        if guest.bookings.any?
          Rails.logger.error("can't destroy guest as it still has bookings. Check user_id: #{guest.id}")
        else
          guest.destroy
        end
      end
    end
  end

end
