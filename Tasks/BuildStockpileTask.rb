class BuildStockpileTask < Task
  attr_reader :position, :width, :height, :building, :settings, :barrels, :bins

  def initialize(name, dependencies, position, width, height, settings, barrels, bins)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = position
    @width = width
    @height = height

    @settings = settings
    @barrels = barrels
    @bins = bins

    @building = :Nil
  end

  def start()
    @started = true
    puts "Starting " + @name

    real_pos = [@position[0] + $offset[0], @position[1] + $offset[1], @position[2] + $offset[2]]

    df.world.buildings.all.each {|b|
      if (b.x1 == real_pos[0] && b.y1 == real_pos[1] && b.z == real_pos[2] && b.class.to_s == "DFHack::BuildingStockpilest")
        @building = b
        #puts("Building already exists: " + b.class.to_s)
      end
    }

    if (@building == :Nil)
      puts("Creating building")
      @building = DFHack.building_alloc(:Stockpile)
      DFHack.building_position(@building, real_pos, @width, @height)
      DFHack.building_construct_abstract(@building)
      @building.room.x = real_pos[0]
      @building.room.y = real_pos[1]
      @building.room.width = @width
      @building.room.height = @height
      #@building.room.extents = Array.new(@width * @height, 1)
      @building.room.extents = DFHack.malloc(@width * @height)
      (0..(width*height-1)).each do |i|
        @building.room.extents[i] = 1
      end
      if (@width == 7 and @height == 7)
        # hack for 7x7 stockpile pods to remove the staircase tile
        @building.room.extents[24] = 0
      end

      #puts(@building)
      @building.name = @name
    end

    checkFinished()
  end

  def checkFinished()
    return true if @finished

    if @building != :Nil

      puts("Loading settings to " + @name)
      df.dfhack_run "loadstockbyname --name " + @name + " stocksettings/" + @settings

      size = @width * @height
      # we have to use a command for this because the loadstock command runs later and overrides it
      puts "setting bins and barrels"
      df.dfhack_run "setbins %i barrels %i" % [@building.id, @barrels && size > 2 ? size - 2 : 0]
      df.dfhack_run "setbins %i bins %i" % [@building.id, @bins && size > 2 ? size - 2 : 0]

      @finished = true
      return true
    else
      return false
    end
  end
end

puts "Loaded class BuildStockpileTask"
