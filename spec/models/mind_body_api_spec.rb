require 'rails_helper'

RSpec.describe MindBodyApi, type: :model do

  # TODO :get_classes
  # TODO :get_custom_client_fields
  # TODO :get_staff
  # TODO :get_staff_img_url
  # TODO :get_locations
  # TODO :add_user
  # TODO :get_user

  context '#get_shoe_size' do
    it 'requires a user or a user id as arguments' do
      expect { MindBodyApi.new.get_shoe_size() }.to raise_exception('id or user must be supplied.')
    end

    it 'gets the shoe size for a user id' do
      shoe_size = MindBodyApi.new.get_shoe_size(id: 24)
      expect(shoe_size).to eq '10.5'
    end

    it 'gets the shoe size for a user id' do
      user = create(:user, id: 24)
      shoe_size = MindBodyApi.new.get_shoe_size(user: user)
      expect(shoe_size).to eq '10.5'
    end

  end

  context '#get staff' do

    it 'gets and parses staff members' do
      staff_members = MindBodyApi.new.get_staff
      expect(staff_members.count).to eq 11

      staff = staff_members[4]
      expect(staff.id).to eq 3
      expect(staff.name).to eq 'CHRISTINE TESSARO'
      expect(staff.image_url).to eq 'https://clients.mindbodyonline.com/studios/SPOKEHAUS/staff/3_large.jpg?imageversion=1452944336'
      expect(staff).to_not be_male
      expect(staff.bio).to_not be_present
    end

  end

end
