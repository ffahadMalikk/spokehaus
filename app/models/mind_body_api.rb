class MindBodyApi
  attr_accessor :client_service,
              :class_service,
              :staff_service,
              :site_service,
              :sale_service,
              :cache

  cattr_accessor :base_url

  delegate :get_custom_client_fields,
           to: :client_service

  delegate :get_locations,
           to: :site_service

  # HACK for program ID
  PROGRAM_ID = 22
  LOCATION_ID = 1

  class ClassNotFoundError < StandardError
    def initialize(id, start_time, end_time)
      super "Could not find class: #{id}, between #{start_time} and #{end_time}"
    end
  end

  def initialize(config = nil, cache = MindBodyApi::Cache.new)
    cfg = config || Rails.application.secrets.mindbody

    base_url = self.class.base_url
    if base_url.present?
      cfg[:base_url] = base_url
    end

    @client_service = MindBody::ClientService.new(cfg)
    @class_service = MindBody::ClassService.new(cfg)
    @staff_service = MindBody::StaffService.new(cfg)
    @site_service = MindBody::SiteService.new(cfg)
    @sale_service = MindBody::SaleService.new(cfg)
    @shoe_size_field_id = cfg[:shoe_size_field_id]
    @cache = cache
  end

  def add_user(id:, email:, first_name:, middle_name: nil, last_name:, birthday:, shoe_size:)
    params = {
      'ID' => id,
      'Email' => email,
      'BirthDate' => birthday,
      'FirstName' => first_name,
      'MiddleName' => middle_name,
      'LastName' => last_name,
      'State' => 'ON',
      'Country' => 'CA',
      'EmailOptIn' => true,
      'PromotionalEmailOptIn' => true,
      'CustomClientFields' => MindBody::Soap.to_array_of('CustomClientField', {
        'ID' => @shoe_size_field_id,
        'Value' => shoe_size
      })
    }
    client_service.add_client(params)
  end

  def update_user(id:, email:, first_name:, middle_name: nil, last_name:, birthday:, shoe_size:)
    params = {
      'ID' => id,
      'Email' => email,
      'BirthDate' => birthday,
      'FirstName' => first_name,
      'MiddleName' => middle_name,
      'LastName' => last_name,
      'EmailOptIn' => true,
      'PromotionalEmailOptIn' => true,
      'CustomClientFields' => MindBody::Soap.to_array_of('CustomClientField', {
        'ID' => @shoe_size_field_id,
        'Value' => shoe_size
      })
    }
    client_service.update_client(params)
  end

  def get_user(id)
    raise 'id must be given' if id.blank?
    client_service.get_clients(id).first
  end

  def get_all_users
    client_service.get_clients_by_string('')
  end

  def get_shoe_size(id: nil, user: nil)
    user_id = id || user.try(:id)
    raise 'id or user must be supplied.' if user_id.blank?

    response = get_user(user_id)
    fields = response.fetch(:custom_client_fields, {}) || {}
    fields.fetch(:custom_client_field, {})[:value]
  end

  # get all staff members
  def get_staff
    staff_service.get_staff
      .map { |staff_hash| Staff.parse(staff_hash) }
  end

  def get_staff_img_url(staff_id)
    raise 'staff_id must be supplied' if staff_id.nil?
    staff_service.get_staff_img_url(staff_id)
  end

  def get_classes(start_time: nil, end_time: nil, hide_canceled_classes: false, fields: [])
    classes = class_service.get_classes(
      start_date_time: start_time,
      end_date_time: end_time,
      hide_canceled_classes: hide_canceled_classes,
      fields: fields,
      program_ids: Array.wrap(PROGRAM_ID),
      location_ids: Array.wrap(1)
    )

    classes.map do |cls|
      ScheduledClass.parse(cls)
    end
  end

  def get_class(id:, start_time: nil, end_time: nil, fields: [])
    classes = class_service.get_classes(
      class_ids: [id],
      start_date_time: tz_hack.convert_local_to_mindbody(start_time),
      end_date_time: tz_hack.convert_local_to_mindbody(end_time),
      fields: fields
    )

    if classes.empty?
      raise ClassNotFoundError.new(id, start_time, end_time)
    else
      ScheduledClass.parse(classes.first)
    end
  end

  def enrolled_in?(class_id:, start_time:, end_time:, client_id:, fields: [])
    classes = class_service.get_classes(
      class_ids: [class_id],
      client_id: client_id,
      start_date_time: tz_hack.convert_local_to_mindbody(start_time),
      end_date_time: tz_hack.convert_local_to_mindbody(end_time),
      fields: fields
    )

    if classes.empty?
      raise ClassNotFoundError.new(class_id, start_time, end_time)
    else
      classes.first[:is_enrolled]
    end
  end

  def get_sites
    site_service.get_sites
  end

  def get_services
    sale_service.get_services(LOCATION_ID).map do |params|
      Package.parse(params)
    end
  end

  def get_activation_code
    site_service.get_activation_code
  end

  def checkout_shopping_cart(client_id:, items:, payments:, test: false)
    payment_hashes = Array.wrap(payments).map(&:to_h)
    sale_service.checkout_shopping_cart(
      location_id: LOCATION_ID,
      client_id: client_id,
      cart_items: items.to_h,
      payments: payment_hashes,
      test: test
    )
  end

  def remove_clients_from_classes(client_ids, class_ids, late_cancel: false)
    class_service
      .remove_clients_from_classes(
        client_ids,
        class_ids,
        late_cancel: late_cancel
      )
  end

  def get_client_services(client_id:, program_id: PROGRAM_ID, session_type_id: nil)
    client_service.get_client_services(
      client_id: client_id,
      session_type_ids: session_type_id,
      program_ids: program_id,
      show_active_only: true
    )
  end

  def get_remaining_credits(client_id, program_id: PROGRAM_ID, allow_cached: false)
    cached = cache.get(remaining_credits_cache_key(client_id))
    return cached if cached.present? && allow_cached

    services = get_client_services(client_id: client_id, program_id: program_id)
    credits = services.reduce(0) do |memo, svc|
      memo + svc[:remaining].to_i
    end

    cache.put(remaining_credits_cache_key(client_id), credits)
    credits
  end

  def get_client_purchases(client_id)
    client_service.get_client_purchases(client_id, start_date: Date.new(2015))
  end

  def get_client_account_balances(client_id)
    client_service.get_client_account_balances(client_id)
  end

  def get_sale(sale_id)
    sale_service.get_sales(sale_id)
  end

  def store_card(client_id:, card:)
    client_service.add_credit_card_to_client(
      client_id: client_id,
      card_number: card.number_stripped,
      card_holder: card.name_on_card,
      city: card.city,
      address: card.address,
      state: card.province,
      postal_code: card.postal_code,
      exp_month: card.expiry.month,
      exp_year: card.expiry.year
    )
    true
  rescue MindBody::ApiError => e
    Rails.logger.error(e.message)
    false
  end

  def get_client_schedule(client_id, start_date: nil, end_date: nil)
    client_service.get_client_schedule(client_id, start_date: start_date, end_date: end_date)
  end

  def book_client_to_class(client_id, scheduled_class, bikes: 1, client_service_id:)
    cache.clear(remaining_credits_cache_key(client_id))

    # this call returns what looks like class info, but it doesn't contain
    # the number of client's booked to this class. It maybe stale, or the
    # call is scoped to the client and therefore unable to return that info

    # add the client once per bike they want to reserved
    client_ids = bikes.times.map { client_id }

    # add the new bookings
    result = class_service.add_clients_to_classes(client_ids, scheduled_class.id, {
      client_service_id: client_service_id
    }).first

    is_enrolled = enrollment_statuses(result).all? do |status|
      status == 'Added'
    end

    # go back to the server for updated booked count
    updated_class_info = self.get_class(
      id: scheduled_class.id,
      start_time: scheduled_class.start_time,
      end_time: scheduled_class.end_time,
    )

    # update the booked count locally
    # TODO this doesn't actually do anything ATM.
    scheduled_class.booked = updated_class_info.booked

    is_enrolled
  end

  def purchase(client_id, item:, payment:, type: 'Service')
    purchase = MindBody::Purchase.new
    purchase.add_item(item, type)

    checkout_shopping_cart(
      client_id: client_id,
      items: purchase,
      payments: payment,
    )
    cache.clear(remaining_credits_cache_key(client_id))
  end

  def get_programs
    site_service.get_programs
  end

  # Removes the client from the class. Includes all the bookings for the
  # client ids
  def cancel_booking(booking, late_cancel: false)
    cache.clear(remaining_credits_cache_key(booking.user_id))

    client_ids = [booking.user_id]
    class_ids = [booking.scheduled_class_id]

    result = self.remove_clients_from_classes(
      client_ids,
      class_ids,
      late_cancel: late_cancel
    )
    success = enrollment_statuses(result.first).all? do |status|
      status == 'Removed'
    end

    unless success
      context = {booking: booking.attributes}
      Honeybadger.notify("Failed to cancel a booking", context: context)
    end

    success
  end

  private

  def tz_hack
    @tz_hack ||= TimeZoneHack.new
  end

  def remaining_credits_cache_key(user_id)
    [:remaining_credits, user_id].join('-')
  end

  def enrollment_statuses(result)
    wrapper = result.fetch(:clients, {})
    Array.wrap(wrapper[:client]).map do |client|
      client[:action]
    end
  end

end
