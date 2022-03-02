module InstructorsHelper

  def instructor_first_name(instructor)
    instructor.name.partition(' ').first
  end

end
