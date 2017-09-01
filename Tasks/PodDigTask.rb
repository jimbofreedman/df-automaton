require "hack/scripts/automaton/Tasks/DigTask.rb"

class PodDigTask < DigTask
  attr_reader :coords, :csv

  def initialize(name, dependencies, coords, stairs, edges)
    puts("=========== " + name)

    @started = false
    @finished = false
    @name = name

    @stringDependencies = dependencies

    @coords = coords

    @csv = Array.new
    @csv[0] = Array.new(10, " ")
    (1..8).each do |y|
      @csv << Array.new(10, (y > 0 && y < 9) ? "d" : " ")
      @csv[y][0] = " "
      @csv[y][9] = " "
    end
    @csv[9] = Array.new(10, " ")

    @csv[4][4] = stairs
    @csv[4][5] = stairs
    @csv[5][4] = stairs
    @csv[5][5] = stairs

    if edges.include? "n"
      @csv[0][4] = "d"
      @csv[0][5] = "d"
    end

    if edges.include? "w"
      @csv[4][0] = "d"
      @csv[5][0] = "d"
    end

    if edges.include? "s"
      @csv[9][4] = "d"
      @csv[9][5] = "d"
    end

    if edges.include? "e"
      puts("MIAOW")
      @csv[4][9] = "d"
      @csv[5][9] = "d"
    end

    puts "printing"
    @csv.each {|e| puts e.join(" ")}
    puts "done"
  end
end

puts "Loaded class PodDigTask"
