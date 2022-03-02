class Booking::Presenter < SimpleDelegator

  def initialize(booking, user)
    super(booking)
    @scheduled_class = booking.scheduled_class
    @user = user
  end

  def bikes
    @bikes ||= Bike::WithReservations.for(scheduled_class).
      map do |bike|
        BikePresenter.new(bike, @user)
      end
  end

  def form
    [scheduled_class, booking]
  end

  def instructor
    scheduled_class.staff
  end

  def instructor_image_url
    parameterized = if instructor.present?
      instructor.name.parameterize
    else
      "unknown"
    end
    "instructors/thumbs/#{parameterized}-bw.jpg"
  end

  def class_name
    scheduled_class.name
  end

  def time
    I18n.l(self.scheduled_class.start_time, format: :booking)
  end

  def meta
    class_date = I18n.l(self.scheduled_class.start_time, format: :short_day)
    class_time = I18n.l(self.scheduled_class.start_time, format: :short_time)

    title = I18n.t('meta.title.bookings',
      class_name: self.class_name,
      class_time: self.time)

    description = I18n.t('meta.description.bookings',
      class_name: self.class_name,
      class_date: class_date,
      class_time: class_time,
      class_instructor: (
        self.scheduled_class.staff.try(:name) || "Unknown Instructor"
      )
    )

    {
      title: title,
      description: description,
      og: {
        title: title,
        description: description
      }
    }
  end

  private

  attr_reader :scheduled_class

  def booking
    __getobj__
  end

  class BikePresenter < SimpleDelegator
    def initialize(bike, user)
      super(bike)
      @user = user
    end

    def selector_options
      options = {multiple: true}

      # the user can select the bike if it is not already reserved, or if she
      # was the one to reserve it
      own_booking = booking.user_id == @user.id
      not_selectable = self.unavailable? || (booking.is_reserved && !own_booking)

      if not_selectable
        options.merge(disabled: :disabled)
      else
        options
      end
    end

    private

    def booking
      __getobj__
    end
  end

end
