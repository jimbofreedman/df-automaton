load('BuildTask.rb')

class BuildStockpileTask < BuildTask
  def start()
    if (!@digFinished)
      return false
    end

    @started = true
    puts "Starting " + @name
    checkFinished()

    if (@building == nil)
      @building = DFHack.building_alloc(@type)
      DFHack.building_position(@building, @pos, @size[0], @size[1])
      DFHack.building_construct_abstract(@building)
      @building.name = @name
      @building.room.x = @pos[0]
      @building.room.y = @pos[1]
      @building.room.width = @size[0]
      @building.room.height = @size[1]
      area = @size[0] * @size[1]
      @building.room.extents = DFHack.malloc(area)
      (0..(area-1)).each do |i|
        @building.room.extents[i] = 1
      end

      @started = true
    end

    checkFinished()
  end

  def checkFinished()
    if !@digFinished or !@digStarted
      return false
    end
    
    puts "BuildStockpileTask Checking finished for " + @name
    findBuilding()
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
    @building.name = @name
    puts("Finalizing %s" % @name)
    puts(@details)
    settings = @details[:option1]
    barrels = @details[:option2]
    bins = @details[:option3]
    df.dfhack_run "loadstockbyname --name " + @name + " stocksettings/" + settings
    area = @size[0] * @size[1]
    # we have to use a command for this because the loadstock command runs at the end of the tick and overrides it
    df.dfhack_run "setbins %i barrels %i" % [@building.id, barrels && area > 2 ? area - 2 : 0]
    df.dfhack_run "setbins %i bins %i" % [@building.id, bins && area > 2 ? area - 2 : 0]
  end

  def getBuildingItems()
    return []
  end
end

puts "Loaded class BuildTask"
