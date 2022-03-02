module PackageHelper

  def price(product)
    number_to_currency product.sub_total, unit: ''
  end

  def price_per_class(product)
    number_to_currency product.sub_total / product.count, unit: ''
  end
end
