class Phase
  attr_reader :name, :tasks

  def initialize(name, tasks)
    @name = name
    @deps = Array.new
    @tasks = tasks

    @finished = false
  end

  def checkFinished()
    if @finished
      return true
    end

    @finished = @tasks.all? { |t| t.finished }
    return @finished
  end

  def print()
    puts("=============================================")
    puts(@name)
    puts("=============================================")
    @tasks.each do |t|
      t.print()
    end
  end
end
