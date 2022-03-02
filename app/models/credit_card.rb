CreditCard = Struct.new(
  :number,
  :address,
  :city,
  :province,
  :postal_code,
  :name_on_card,
  :expiry
) do

  def valid?
    self.values.all? &:present?
  end

  def number_stripped
    number.gsub(/\D/, '')
  end

  def last_four
    if number_stripped.length == 16
      number_stripped[-4, 4]
    end
  end

end