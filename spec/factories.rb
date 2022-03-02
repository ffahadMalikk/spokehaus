FactoryGirl.define do

  factory :gift do
    recipient_email { create(:registered_user).email }
    sender { build(:user) }
    credits 1
    message Faker::Lorem.sentence(3)
  end

  factory :package do
    price_in_cents 999
    tax_rate 0.13
    name { Faker::Commerce.product_name }
    count 1

    factory :one_ride_package do
      id 10101
    end
    after(:create) do |p|
      FakeMindBodyApi::Application.register_package(p)
    end
  end

  factory :scheduled_class do
    sequence(:id)
    sequence(:class_id)
    capacity 3
    name { Faker::Lorem.words(2).join(' ').titlecase }
    description { Faker::Lorem.sentence }
    start_time { Time.zone.now + 10.hours }
    end_time { Time.zone.now + 11.hours }
    staff
  end

  factory :staff do
    name {Faker::Name.name}
    is_male false

    factory :instructor do
      image_url { Faker::Avatar.image }
    end
  end

  factory :booking do
    bikes { create_list :bike, 1 }
    scheduled_class
    user
    status :booked
  end

  factory :bike do
    sequence(:position)
  end

  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    birthdate { Faker::Date.between(85.years.ago, 18.years.ago) }
    name { Faker::Name.name }

    factory :guest do
      status :guest
    end

    factory :registered_user do
      status :registered
    end

    factory :admin do
      status :registered
      role :admin
    end

    after(:create) do |user|
      if user.registered?
        FakeMindBodyApi::Application.inject_user(
          id: user.id,
          name: user.name,
          email: user.email,
          shoe_size: user.shoe_size,
          birthdate: user.birthdate,
          credits: 0
        )
      end
    end
  end

end
