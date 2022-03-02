class InstructorsController < ApplicationController

  def index
    @instructors = scope.all
  end

  def show
    @instructor = scope.find(params.fetch(:id))
  end

  private

  def scope
    Staff.exclude_system
  end

end
