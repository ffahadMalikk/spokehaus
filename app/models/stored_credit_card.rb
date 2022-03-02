StoredCreditCard = Struct.new(:last_four_int, :expiry_date) do

  def expired?
    expiry_date.nil? || Date.today >= expiry_date
  end

  def present?
    last_four.present? && expiry_date.present?
  end

  def number
    "xxxx-xxxx-xxxx-#{last_four}"
  end

  def expiry
    I18n.l(expiry_date.to_date, format: :cc)
  end

  def last_four
    last_four_int.to_s.rjust(4, "0")
  end

end
