class PurchaseResult
  attr_reader :status, :form, :package, :error_message

  def self.invalid(form)
    new(:invalid, form: form)
  end

  def self.ok(package)
    new(:ok, package: package)
  end

  def self.error(error)
    new(:error, error: error)
  end

  def initialize(status, form: nil, package: nil, error: nil)
    @status = status
    @form = form
    @package = package
    @error_message = error.try(:error_message)
  end

  def ok?
    @status == :ok
  end

  def credits_purchased
    package.count
  end

end
