module BookingHelper

  def new_or_edit_path(scheduled_class)
    case
    when scheduled_class.locked?
      '#'
    when scheduled_class.is_booked?
      edit_booking_path(scheduled_class.user_booking_id)
    else
      new_scheduled_class_booking_path(scheduled_class)
    end
  end

  def cancel_booking_button(booking)
    if booking.can_cancel?
      confirm_translation_key = (booking.late_cancel? ? 'bookings.cancel_confirm_late' : 'bookings.cancel_confirm_early')
      button_to booking_path(booking.id), method: :delete, data: { disable_with: t('label.please_wait'), confirm: t(confirm_translation_key) }, class: 'button-cancel' do
        t('label.cancel_booking')
      end
    else
      button_to '#', disabled: true, class: 'button-cancel', alt: "The class has already started." do
        t('label.cancel_booking')
      end
    end
  end

end
