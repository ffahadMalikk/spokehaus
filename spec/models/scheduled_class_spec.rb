require 'rails_helper'

RSpec.describe ScheduledClass, type: :model do

  context 'parsing' do

    it 'parses id' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.id).to eq 123
    end

    it 'parses class_id' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.class_id).to eq "234"
    end

    it 'parses name' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.name).to eq 'Power Yoga'
    end

    it 'parses description' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.description).to eq "It's yoga, but more powerful"
    end

    it 'parses start_time' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.start_time).to eq Time.zone.local(2015, 12, 10, 8)
    end

    it 'parses end_time' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.end_time).to eq Time.zone.local(2015, 12, 10, 8, 30)
    end

    it 'parses capacity' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.capacity).to eq 20
    end

    it 'parses booked' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.booked).to eq 19
    end

    it 'parses waitlisted' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.waitlisted).to eq 0
    end

    it 'parses is_available' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.available?).to eq true
    end

    it 'parses is_canceled' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.canceled?).to eq false
    end

    it 'parses staff' do
      schedule = ScheduledClass.parse(create_class_response)
      expect(schedule.staff.id).to eq 345
    end

  end

  it 'is sorted by start_time' do
    c1 = create(:scheduled_class,
      start_time: Time.zone.local(2015, 11, 8, 10, 30),
      end_time:   Time.zone.local(2015, 11, 8, 11, 30))

    c2 = create(:scheduled_class,
      start_time: Time.zone.local(2015, 11, 8, 9, 30),
      end_time:   Time.zone.local(2015, 11, 8, 10, 30))

    week = WeekOf.new(Time.zone.local(2015, 11, 12))
    classes = ScheduledClass.between(week.start, week.end)

    expect(classes.map(&:id)).to eq [c2.id, c1.id]
  end

  def create_class_response(params = {})
    create(:staff, {
      id: 345,
      name: 'Ben Moss',
      image_url: nil,
      is_male: true,
    })
    params.reverse_merge(
      id: 123,
      start_date_time: '2015-12-10T08:00:00',
      end_date_time: '2015-12-10T08:30:00',
      max_capacity: 20,
      total_booked: 19,
      total_booked_waitlist: 0,
      is_available: true,
      is_canceled: false,
      class_description: {
        id: 234,
        name: 'Power Yoga',
        description: "It's yoga, but more powerful",
      },
      staff: {
        id: 345,
        name: 'Ben Moss',
        image_url: nil,
        is_male: true,
      }
    )
  end

end
