require 'rails_helper'

RSpec.describe CalendarController, type: :controller do

  it 'creates a schedule of classes grouped by date' do
    Timecop.freeze(Opening::Day) do
      late_tuesday_class = create(:scheduled_class,
        start_time: Opening::Day + 1.day + 10.hours + 30.minutes)
      thursday_class = create(:scheduled_class,
        start_time: Opening::Day + 3.day + 11.hours + 30.minutes)
      early_tuesday_class = create(:scheduled_class,
        start_time: Opening::Day + 1.day + 9.hours + 30.minutes)

      get :show

      calendar = assigns(:calendar)
      expect(calendar.days.length).to eq 7

      tuesday = calendar.days[2]
      expect(tuesday.date).to eq Time.zone.local(2016, 2, 9)
      expect(tuesday.scheduled_classes).to eq [early_tuesday_class, late_tuesday_class]

      thursday = calendar.days[4]
      expect(thursday.date).to eq Time.zone.local(2016, 2, 11)
      expect(thursday.scheduled_classes).to eq [thursday_class]
    end
  end

end
