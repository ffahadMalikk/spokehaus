require 'rails_helper'

RSpec.describe WeekOf, type: :model do
  dates = [8, 9, 10, 11, 12, 13, 14].map {|day| Date.new(2015, 11, day)}

  dates.each do |date|
    it "has the correct first and last day on #{date.strftime('%A')}" do
      week = WeekOf.new(date)
      expect(week.first_day).to eq Date.new(2015, 11, 8).beginning_of_day
      expect(week.last_day).to eq Date.new(2015, 11, 14).end_of_day
    end
  end

  it 'has a range of the days of the week' do
    week = WeekOf.new(Date.new(2015, 11, 12))
    names = week.range.map { |d| d.strftime('%A') }
    expect(names).to eq %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  end

  it 'includes the start of the first day' do
    week = WeekOf.new(Date.new(2015, 11, 12))
    first_moment = Date.new(2015, 11, 8).beginning_of_day
    expect(week.start).to eq first_moment
  end

  it 'includes the end of the last day' do
    week = WeekOf.new(Date.new(2015, 11, 12))
    last_moment = Date.new(2015, 11, 14).end_of_day
    expect(week.end).to eq last_moment
  end
end
