class BuildBridgeTask < Task
  attr_reader :position, :width, :height, :type, :subtype, :building, :direction

  def initialize(name, dependencies, position, width, height, direction)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = [position[0] + $offset[0], position[1] + $offset[1], position[2] + $offset[2]]
    @width = width || 1
    @height = height || 1

    @type = :Bridge
    @direction = direction

    @className = 'DFHack::BuildingBridgest'
    @building = :Nil
  end

  def findBuilding()

    df.world.buildings.all.each {|b|
      if (b.x1 == @position[0] && b.y1 == @position[1] && b.z == @position[2] && b.class.to_s == @className)
        @building = b
        puts("Building already exists: " + b.class.to_s)
      end
    }
  end

  def start()
    puts "Starting " + @name

    findBuilding()

    if (@building == :Nil)
      puts("Creating building")

      items = getBuildingItems()
      if (items == false)
        puts("Couldn't get items for building, waiting")
        return
      end

      @building = DFHack.building_alloc(@type, @subtype, @custom=0) # hardcode 0 for soapmaker, ignored otherwise
      DFHack.building_position(@building, @position, @width, @height)
      puts(items)
      DFHack.building_construct(@building, items)
      puts(@building)
      @building.direction = @direction

      @started = true
    end

    checkFinished()
  end

  def checkFinished()
    puts "Checking Finished " + @name
    # if @finished
    #   return true
    # end

    findBuilding()
    if @building != :Nil
      if @building.flags.exists
        @started = true
        @finished = true
        if (@jobs != nil && @jobs.length > 0)
          addJobs()
        end
        puts("Done checkfinished")
        return true
      else
        # unsuspend construction
        if (@building.jobs[0] != nil)
          @building.jobs[0].flags.suspend = false
        end
      end
    end
    return false
  end

  def getBoulder()
    item = df.world.items.all.find { |i|
        i.kind_of?(DFHack::ItemBoulderst) and
        DFHack.item_isfree(i)
    }
    return item != nil ? [item] : false
  end

  def getBuildingItems()
    case @type
    when :Construction
      case @subtype
      when :Wall
        puts("Returning for wall")
        i = getBoulder()
        puts(i)
        return i
      end
    end
    return []
  end
end

puts "Loaded class BuildBridgeTask"
