module Pages
  class SignIn < Base

    def visit_page
      visit new_user_session_path
    end

    def sign_in(email:, password:)
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      within('.actions') do
        click_on 'Sign In'
      end
    end

  end
end
