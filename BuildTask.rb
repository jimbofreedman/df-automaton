load('Task.rb')

class BuildTask < Task
  attr_reader :name, :digStarted, :digFinished, :started, :finished, :debugging
  attr_writer :debugging

  def initialize(name, pos, size, details)
    @name = name
    @digStarted = false
    @digFinished = false
    @started = false
    @finished = false
    @digType = 'd'

    @pos = pos
    @size = size
    @details = details


    puts("Initializing %s" % @name)
    puts(details)
    @type = details[:type]
    @subtype = details[:subtype]
    @className = DFHack.rtti_n2c[DFHack::BuildingType::Classname[@type].to_sym]

    initCSV()

    @debugging = false

    findBuilding()
  end

  def findBuilding()
    df.world.buildings.all.each {|b|
      if (b.class == @className)
        if (b.x1 == @pos[0] && b.y1 == @pos[1] && b.z == @pos[2])
          @building = b
          puts("Building already exists: " + b.class.to_s)
        end
      end
    }
  end

  def start()
    if (!@digFinished)
      return false
    end

    @started = true
    puts "Starting " + @name
    checkFinished()

    if (@building == nil)
      findBuilding()
    end

    if (@building == nil)
      items = getBuildingItems()
      if (items == false or items.include?(nil))
        return
      end

      puts("%s %s %s" % [@type, @subtype, @custom])
      if (@subtype != nil)
        @building = DFHack.building_alloc(@type, @subtype, @custom=0) # hardcode 0 for soapmaker, ignored otherwise
      else
        @building = DFHack.building_alloc(@type)
      end

      if @type == :Workshop || @type == :Furnace
        DFHack.building_position(@building, @pos)
      else
        DFHack.building_position(@building, @pos, @size[0], @size[1])
      end

      if @type == :Stockpile || @type == :CivZone || @type == :FarmPlot
        DFHack.building_construct_abstract(@building)
      else
        DFHack.building_construct(@building, items)
      end

      @building.name = @name
      # if (@type == :Trap and @building.jobs[0])
      #   @building.jobs[0].flags.do_now = true
      # end

      @started = true
    end

    checkFinished()
  end

  def checkFinished()
    if !@digFinished or !@digStarted
      return false
    end
    
    puts "BuildTask Checking finished for " + @name
    if @started
      if @building != nil
        if @building.flags.exists
          @started = true
          @finished = true
          # if (@jobs != nil && @jobs.length > 0)
          #   addJobs()
          # end
          puts("Done checkfinished")
          finalizeBuild()
          return true
        else
          # unsuspend construction
          if (@building.jobs[0])
            @building.jobs[0].flags.suspend = false
          end
        end
      end
      return true
    end
  end

  def finalizeBuild()

  end

  def getBuildingItems()
    return []
  end
end

puts "Loaded class BuildTask"
