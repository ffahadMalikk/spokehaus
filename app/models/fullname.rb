class Fullname
  def initialize(fullname)
    @chunks = fullname.split(' ')
  end

  def first
    @chunks.slice(0)
  end

  def last
    @chunks.slice(-1)
  end

  def middle
    if @chunks.length > 2
      @chunks.slice(1, @chunks.length-2).join(' ')
    else
      nil
    end
  end
end
