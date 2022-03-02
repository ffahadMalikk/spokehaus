class AddMoreBikes < ActiveRecord::Migration

  # NUM = 5
  #
  # def up
  #   last_bike_position = Bike.order(:position).last.position
  #   NUM.times do |i|
  #     Bike.create(position: last_bike_position + 1 + i)
  #   end
  #
  #   Bike.update_all('id=position')
  # end
  #
  # def down
  #   Bike.last(NUM).map &:destroy
  # end
end
