load "hack/scripts/automaton/Tasks/BuildTask.rb"

class BuildPressurePlateTask < BuildTask
  attr_reader :settings

  def initialize(name, dependencies, position, settings)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = [position[0] + $offset[0], position[1] + $offset[1], position[2] + $offset[2]]
    @width = width || 1
    @height = height || 1

    @type = :Trap
    @subtype = :PressurePlate
    @settings = settings

    @className = DFHack.rtti_n2c[DFHack::BuildingType::Classname[@type].to_sym]
    @building = nil
  end

  def start()
    puts "Starting " + @name

    findBuilding()

    if (@building == nil)
      puts("Creating building")

      items = getBuildingItems()
      if (items == false)
        puts("Couldn't get items for building, waiting")
        return
      end

      @building = DFHack.building_alloc(@type, @subtype, @custom=0) # hardcode 0 for soapmaker, ignored otherwise
      DFHack.building_position(@building, @position)

      puts(items)
      DFHack.building_construct(@building, items)
      puts(@building)

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
    if @building != nil
      if @building.flags.exists
        @started = true
        @finished = true
        @building.plate_info.water_min = @settings[:WaterMin]
        @building.plate_info.water_max = @settings[:WaterMax]
        @building.plate_info.flags.water = (@settings[:WaterMin] != nil)
        @building.plate_info.flags.resets = @settings[:Resets]
        #puts("Done checkfinished")
        return true
      else
        # unsuspend construction
        @building.jobs[0].flags.suspend = false
      end
    end
    return false
  end
end

puts "Loaded class BuildPressurePlateTask"
