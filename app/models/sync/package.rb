class Sync::Package < Sync::Base

  def initialize
    super(Package)
  end

  def slice_incoming_attrs(model, record)
    attrs = %w(id price_in_cents tax_rate name count)
    record.attributes.slice(*attrs)
  end

end
