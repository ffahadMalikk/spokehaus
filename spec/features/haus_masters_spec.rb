require 'rails_helper'

describe 'Viewing the list of staff' do

  scenario 'a user views the current week' do
    3.times { create(:instructor) }

    visit instructors_path

    staff_elements = all('.instructor')
    expect(staff_elements.count).to eq 3
  end

end
