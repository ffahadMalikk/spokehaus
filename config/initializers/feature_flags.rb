class FeatureFlags
  attr_accessor :flags

  def initialize(flags)
    @flags = flags
  end

  def comp_first_ride?
    @flags.fetch(:comp_first_ride)
  end

  def friend_credits?
    @flags.fetch(:friend_credits)
  end

end

Flags = FeatureFlags.new(
  comp_first_ride: false,
  friend_credits: false
)
