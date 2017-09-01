require "hack/scripts/automaton/Task.rb"

class DigTask < Task
  attr_reader :coords, :csv

  def initialize(name, dependencies, coords, csv, part)
    @started = false
    @finished = false
    @name = name

    @stringDependencies = dependencies

    @coords = coords

    planfile = File.read("plans/" + csv)
    #puts "processing"
    @csv = planfile.map { |l| l.split(";").map {|e|
      e.strip!

      parts = e.split("_")
      # puts "==="
      # puts part
      # puts parts
      if (parts.length > 1)
        # multipart dig
        if parts[1].to_s == part.to_s
          #puts "match" + parts[0]
          parts[0]
        else
#          puts "nomatch"
          ""
        end
      else
        e
      end
    } }
    #  puts "printing"
    #  @csv.each {|e| puts "LINE"; puts e}
    #  puts "done"
  end

  def start()
    @started = true
    puts "Starting " + @name
    @csv.each_with_index { |row, r|
      row.each_with_index { |col, c|
        x = $offset[0] + @coords[0] + c
        y = $offset[1] + @coords[1] + r
        z = $offset[2] + @coords[2]
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

  def innerCheckFinished()
    puts "Checking Finished " + @name
    @csv.each_with_index { |row, r|
      row.each_with_index { |col, c|
        x = $offset[0] + @coords[0] + c
        y = $offset[1] + @coords[1] + r
        z = $offset[2] + @coords[2]

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
    puts @name + " is finished"
    @finished = true
    return @finished
  end

  def checkFinished()
    ret = innerCheckFinished()
    start() if (@started && !@finished)
    ret
  end
end

puts "Loaded class DigTask"
