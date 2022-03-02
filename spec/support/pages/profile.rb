module Pages
  class Profile < Base

    def path
      user_profile_path
    end

    def has_booked_class?(cls)
      page.find('.user-profile-classes', text: cls.name)
    end

    def send_gift
      click_on I18n.t('label.send_gift')
      Pages::NewGift.new
    end

  end
end
