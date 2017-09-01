class BuildFarmTask < Task
  attr_reader :position, :width, :height, :crops, :building

  def initialize(name, dependencies, position, width, height, crops)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = position
    @width = width
    @height = height
    @crops = crops

    @building = nil
  end

  def start()
    @started = true
    puts "Startinga " + @name

    real_pos = [@position[0] + $offset[0], @position[1] + $offset[1], @position[2] + $offset[2]]

    df.world.buildings.all.each {|b|
      if (b.x1 == real_pos[0] && b.y1 == real_pos[1] && b.z == real_pos[2] && b.class.to_s == "DFHack::BuildingFarmplotst")
        #puts(b.class.to_s)
        @building = b
        #puts("Building already exists: " + b.class.to_s)
      end
    }

    if (@building == nil)
      puts("Creating building")
      @building = DFHack.building_alloc(:FarmPlot)
      DFHack.building_position(@building, real_pos, @width, @height)
      DFHack.building_construct(@building, [])
      puts(@building)
    end

    @building.plant_id[0] = @crops[0]
    @building.plant_id[1] = @crops[1]
    @building.plant_id[2] = @crops[2]
    @building.plant_id[3] = @crops[3]
  end

  def checkFinished()
    if (@building != nil)
      @building.plant_id[0] = @crops[0]
      @building.plant_id[1] = @crops[1]
      @building.plant_id[2] = @crops[2]
      @building.plant_id[3] = @crops[3]
      return (@finished = @building.flags.exists)
    end
    return false
  end
end

puts "Loaded class BuildFarmTask"
