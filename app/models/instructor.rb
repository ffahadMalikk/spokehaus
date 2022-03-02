class Instructor

  class << self

    def all
      MindBodyApi.new.get_staff
    end

  end

end
