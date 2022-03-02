class Staff < ActiveRecord::Base

  validates :name, presence: true

  # A special Staff record labelled "Class Cancelled" has ID -1,
  # there are several more with IDs -2, -3, etc.
  scope :exclude_system, -> { where('id > 1') }

  def has_image?
    image_url.present?
  end

  def male?
    is_male
  end

  def to_param
    "#{id}-#{name.downcase.gsub(/\W+/, '-')}"
  end

  def self.parse(params)
    self.new(
      id: params[:id],
      name: params[:name],
      image_url: params[:image_url],
      is_male: params[:is_male],
      bio: params[:bio]
    )
  end

end
