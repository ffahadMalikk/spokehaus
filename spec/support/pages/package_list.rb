module Pages
  class PackageList < Base

    def path
      packages_path
    end

    def purchase(package_id)
      choose "purchase_package_id_#{package_id}"
    end

    def provide_credit_card(credit_card)
      fill_in 'Name on card', with: credit_card.fetch(:card_holder)
      fill_in 'Card number', with: credit_card.fetch(:card_number)
      fill_in 'Billing Address', with: credit_card.fetch(:address)
      fill_in 'City', with: credit_card.fetch(:city)
      fill_in 'Province', with: credit_card.fetch(:province)
      fill_in 'Postal code', with: credit_card.fetch(:postal_code)
      select credit_card.fetch(:expiry_year), from: 'purchase_expiry_year'
      select credit_card.fetch(:expiry_month), from: 'purchase_expiry_month'
    end

    def save_card
      check 'Save card'
    end

    def submit_purchase
      click_on 'Purchase'
      Pages::Calendar.new
    end

  end
end
