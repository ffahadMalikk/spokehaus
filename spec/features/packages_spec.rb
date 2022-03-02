require 'rails_helper'

RSpec.describe 'Packages' do

  scenario 'list of packages' do
    2.times { create(:package) }

    visit packages_path

    packages = all('.package')

    if Flags.comp_first_ride?
      expect(packages.count).to eq 3 # first ride package is hard coded
    else
      expect(packages.count).to eq 2
    end
  end

end
