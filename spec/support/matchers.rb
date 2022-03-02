RSpec::Matchers.define :have_successful_booking_notice_for do |cls|
  match do |page|
    expect(page).to have_content(successful_booking(cls))
  end

  failure_message do |page|
    "expected that #{page.text} would contain \"#{successful_booking(cls)}\""
  end

  def successful_booking(cls)
    I18n.t('successful_booking',
      class_name: cls.name,
      instructor_name: cls.instructor_name,
      start_time: I18n.l(cls.start_time, format: :long))
  end
end


RSpec::Matchers.define :have_booking_pending do
  match do |page|
    expect(page).to have_booking_alert
  end
end

RSpec::Matchers.define :have_booking_pending_credits do
  match do |page|
    expect(page).to have_booking_pending
    expect(page).to have_content(I18n.t('insufficient_credits'))
  end
end

RSpec::Matchers.define :have_booking_pending_registration do
  match do |page|
    expect(page).to have_booking_pending
    expect(page).to have_content(I18n.t('booking_pending_registration'))
  end
end
