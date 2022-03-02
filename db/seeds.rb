# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def ensure_user_created(params)
  user = User.find_by(id: params.fetch(:id))
  if user.nil?
    user = User.create!(params.merge(password: 'changeme'))
  end

  user.update!(params)
end

# Bikes
35.times do |i|
  Bike.where(position: i+1).first_or_create!
end

# Users
ensure_user_created(
  id: '589ff99b-adfa-4c57-8ed1-5fce6408a2b4',
  email: 'ben@unspace.ca',
  shoe_size: 10.5,
  name: 'Ben Moss',
  status: :registered,
  birthdate: Date.new(1976,9,6),
  role: :admin
)

ensure_user_created(
  id: '74985583-6f43-40f3-b96f-ca7fc4995f98',
  email: 'jamie@gilgen.ca',
  shoe_size: 10.5,
  name: 'Jamie Gilgen',
  status: :registered,
  birthdate: Date.new(1981, 10, 22),
  role: :admin
)

ensure_user_created(
  id: '55e37ede-430b-4ca8-980a-520c5bfe932e',
  email: 'christine@spokehaus.ca',
  shoe_size: 9.0,
  name: 'Christine Tessaro',
  status: :registered,
  birthdate: Date.new(1986,3,5),
  role: :admin
)

# Packages
package = Package.find_by(id: Package::INTRO_OFFER)
if package.nil?
  package = Package.create!(
    id: Package::INTRO_OFFER,
    price_in_cents: 2800,
    tax_rate: 0,
    name: "Intro Offer",
    count: 2
  )
end

package.update!(friend_credits: 1)
