module MindBodyModel

  # FactoryGirl.lint will call .save! to ensure factories are valid.
  if Rails.env.test?
    def save!(options={})
      unless valid?
        raise errors.full_messages.join(", ")
      end
    end
  end

end
