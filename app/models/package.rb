class Package < ActiveRecord::Base

  ONE_RIDE = 10101
  INTRO_OFFER = 10161
  UNLIMITED_THRESHOLD = 1000

  scope :visible, -> { where("is_hidden is null or is_hidden='f'") }

  def self.parse(params)
    package = Package.new(
      id: params[:id],
      name: params[:name],
      tax_rate: params[:tax_rate],
      count: params[:count],
    )

    dollar_amount = BigDecimal(params.fetch(:price, 0))
    package.price_in_cents = dollar_amount * 100
    package
  end

  def is_unlimited?
    count > UNLIMITED_THRESHOLD
  end

  def self.one_ride
    Package.find(ONE_RIDE)
  end

  def price
    total
  end

  def sub_total
    (BigDecimal(price_in_cents) / 100).to_f
  end

  def total
    total_with_tax = sub_total + (tax_rate * sub_total)
    total_with_tax.round(2)
  end

  def count_without_friend_credits
    if id == INTRO_OFFER
      count - friend_credits
    else
      count
    end
  end

  def has_friend_credits?
    friend_credits > 0
  end

end
