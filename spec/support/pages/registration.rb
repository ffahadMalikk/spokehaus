module Pages
  class Registration < Base

    def visit_page
      visit path
    end

    def path
      new_user_registration_path
    end

    def register(user_params)
      fill_in 'Name', with: user_params.fetch(:name)
      fill_in 'Email', with: user_params.fetch(:email)
      fill_in 'Password', with: user_params.fetch(:password)
      fill_in 'birthdate', with: user_params.fetch(:birthdate)
      fill_in 'Shoe size', with: user_params.fetch(:shoe_size)

      within('.actions') do
        click_on 'Register'
      end
    end

  end
end
