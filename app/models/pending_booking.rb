class PendingBooking
  attr_reader :booking, :api

  def initialize(booking, api = MindBodyApi.new)
    @booking = booking
    @api = api
  end

  def complete(pricing_options)
    if booking.valid?
      booking.processing!
      begin
        client_ids = total_bikes(pricing_options).times.map { booking.user.id }
        api.remove_clients_from_classes(client_ids, booking.scheduled_class.id)
        pricing_options.each do |pricing_option|
          api.book_client_to_class(
            booking.user.id,
            booking.scheduled_class,
            bikes: pricing_option[:bike_count],
            client_service_id: pricing_option[:id].try(:to_i)
          )
        end
        booking.booked!
      rescue MindBody::ApiError => e
        puts e.message.red
        puts e.backtrace.join("\n").red
        booking.update_attribute(:status_text, e.message)
        booking.failed!
        false
      rescue => e
        Honeybadger.notify(StandardError.new("Unexpected exception in PendingBooking"), context: {
          booking: booking.attributes,
          errors: e.message
        })
        puts e.message.red
        puts e.backtrace.join("\n").red
        booking.update_attribute(:status_text, "An unknown error occurred. Please try again.")
        booking.failed!
        false
      end
    end
  end

  def total_bikes(pricing_options)
    pricing_options.sum { |p| p[:bike_count] }
  end

end
