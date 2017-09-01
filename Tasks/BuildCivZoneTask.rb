class BuildCivZoneTask < Task
  attr_reader :position, :width, :height, :building, :civZoneType, :pastureRace

  def initialize(name, dependencies, position, width, height, civZoneType, pastureRace)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = position
    @width = width
    @height = height

    @civZoneType = civZoneType
    @pastureRace = pastureRace

    @building = :Nil
  end

  def start()
    @started = true
    puts "Starting " + @name
    real_pos = [@position[0] + $offset[0], @position[1] + $offset[1], @position[2] + $offset[2]]

    df.world.buildings.all.each {|b|
      if (b.x1 == real_pos[0] && b.y1 == real_pos[1] && b.z == real_pos[2] && b.class.to_s == "DFHack::BuildingCivzonest")
        @building = b
        #puts("Building already exists: " + b.class.to_s)
      end
    }

    if (@building == :Nil)
      puts("Creating building")
      @building = DFHack.building_alloc(:Civzone)
      DFHack.building_position(@building, real_pos, @width, @height)
      DFHack.building_construct_abstract(@building)
      @building.name = @name
      @building.is_room = true
      @building.type = 9
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
    end
  end

  def checkFinished()
    return true if @finished

    if @building != :Nil
      @finished = true
      @building.zone_flags.active = true
      case @civZoneType
      when :Pasture
        @building.zone_flags.pen_pasture = true
        $Automaton.pastureManager.registerPasture(@building, @pastureRace)
      when :MeetingArea
        @building.zone_flags.meeting_area = true
      when :GarbageDump
        @building.zone_flags.garbage_dump = true
      when :Sand
        @building.zone_flags.sand = true
      when :FishAndDrink
        @building.zone_flags.water_source = true
        @building.zone_flags.fishing = true
      end
      return true
    else
      return false
    end
  end
end

puts "Loaded class BuildCivZoneTask"
