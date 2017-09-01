class Task
  attr_reader :name, :digStarted, :digFinished, :started, :finished, :debugging
  attr_writer :debugging

  def debug(s)
    @debugging = (@debugging ||= false)
    if (@debugging == true)
      puts(s)
    end
  end

  def initialize(name, pos, size, digType)
    @name = name
    @digStarted = false
    @digFinished = false
    @started = false
    @finished = false
    @digType = digType

    @pos = pos
    @size = size

    #puts("Initializing %s" % @name)
    #puts(@size)

    initCSV()

    @debugging = false
  end

  def initCSV()
    @csv = Array.new(@size[1])
    (0..@size[1]-1).each do |r|
      @csv[r] = Array.new(@size[0], @digType)
    end
    #puts(@csv)
  end

  def digStart()
    @digStarted = true
    puts "Starting " + @name
    checkFinished()

    @csv.each_with_index { |row, r|
      row.each_with_index { |col, c|
        x = @pos[0] + c
        y = @pos[1] + r
        z = @pos[2]
        #puts x.to_s + " " + y.to_s + " " + z.to_s + " : [" + col + "]"

        t = df.map_tile_at(x, y, z)

        s = t.shape_basic
        #puts col
        case col
          when 'd'; t.dig(:Default) if s == :Wall
          when 'u'; t.dig(:UpStair) if s == :Wall
          when 'j'; t.dig(:DownStair) if s == :Wall or s == :Floor
          when 'i'; t.dig(:UpDownStair) if s == :Wall
          when 'h'; t.dig(:Channel) if s == :Wall or s == :Floor
          when 'r'; t.dig(:Ramp) if s == :Wall
          when 'x'; t.dig(:No)
          when 'F'
            if (t.special.to_s != "SMOOTH") # smooth first, then carve
              t.dig(:Smooth)
            else
              block = df.map_block_at(x, y, z)
              block.flags.designated = true
              t.designation.smooth = 1 #(t.tiletype == :StonePillar ? 1 : 1)
            end
        end
      }
    }
  end

  def innerDigCheckFinished()
    #puts "Checking Dig Finished " + @name
    @csv.each_with_index { |row, r|
      row.each_with_index { |col, c|
        x = @pos[0] + c
        y = @pos[1] + r
        z = @pos[2]

        t = df.map_tile_at(x, y, z)
        #puts x.to_s + " " + y.to_s + " " + z.to_s
        s = t.shape_basic
        #puts col
        #puts s
        #puts x.to_s + " " + y.to_s + " " + z.to_s + "\t" + col.to_s + "\t" + s.to_s
        case col
          when 'd'; return false if s != :Floor and t.tilemat.to_s != "CONSTRUCTION"
          when 'u'; return false if s != :Stair
          when 'j'; return false if s != :Stair
          when 'i'; return false if s != :Stair
          when 'h'; return false if (s != :Open && s != :Ramp)
          when 'r'; return false if s != :Ramp
          when 'F'; return false if t.shape.to_s != "FORTIFICATION"
          when 'x';
        end
        #puts "next"
      }
    }
    puts @name + " is digfinished"
    @digFinished = true
    return @digFinished
  end

  def digCheckFinished()
    ret = innerDigCheckFinished()
    digStart() if (@digStarted && !@digFinished)
    ret
  end

  def start()
    @started = true
    puts "Starting " + @name
    checkFinished()
  end

  def checkFinished()
    if !@digFinished or !@digStarted
      return false
    end
    
    puts "Checking finished for " + @name
    if @started
      @finished = true
      return true
    end
    return false
  end

  def print()
    puts("D[%s%s] B[%s%s] %i %s" % [@digStarted ? "S" : " ", @digFinished ? "F" : " ", @started ? "S" : " ", @finished ? "F" : " ", @pos[2], @name])
  end
end

puts "Loaded class Task"
