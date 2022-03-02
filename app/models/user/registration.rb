class User::Registration < User
  validate :has_first_and_last_name
  validates :shoe_size, presence: true
  validates :birthdate, presence: true
  validate :user_is_unique_in_minbody
  validate :birthdate_is_not_in_the_future

  before_create :ensure_pending_status
  after_create :create_mind_body_user

  def has_first_and_last_name
    if String(name).split(' ').length < 2
      errors.add(:name, I18n.t(:must_have_2_parts))
    end
  end

  def user_is_unique_in_minbody
    # TODO check against the API for
    # same name, email etc.
  end

  def birthdate_is_not_in_the_future
    if birthdate.present? && birthdate > Date.today
      errors.add :birthdate, 'cannot be in the future'
    end
  end

  def ensure_pending_status
    self.status = :pending
  end

  def create_mind_body_user
    api = MindBodyApi.new
    api.add_user(
      id: id,
      email: email,
      first_name: fullname.first,
      middle_name: fullname.middle,
      last_name: fullname.last,
      birthday: birthdate,
      shoe_size: shoe_size,
    )
    self.registered!
  end

end
