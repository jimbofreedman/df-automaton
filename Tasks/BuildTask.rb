class BuildTask < Task
  attr_reader :position, :width, :height, :type, :subtype, :building, :jobs, :position

  def initialize(name, dependencies, position, type, subtype, jobs)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies

    @position = [position[0] + $offset[0], position[1] + $offset[1], position[2] + $offset[2]]
    @width = width || 1
    @height = height || 1

    @type = type
    @subtype = subtype
    @jobs = jobs || jobs

    @className = DFHack.rtti_n2c[DFHack::BuildingType::Classname[@type].to_sym]
    @building = nil
  end

  def findBuilding()
    df.world.buildings.all.each {|b|
      #puts(b.class)
      if (b.class == @className)
        # puts(b.x1)
        # puts(b.y1)
        # puts(b.z)
        # puts(position[0])
        # puts(position[1])
        # puts(position[2])
        if (b.x1 == @position[0] && b.y1 == @position[1] && b.z == @position[2])
          @building = b
          puts("Building already exists: " + b.class.to_s)
        end
      end
    }
  end

  def start()

    if (@building == nil)
      findBuilding()
    end

    if (@building == nil)
      #puts("Creating building")

      items = getBuildingItems()
      if (items == false or items.include?(nil))
        #puts("Couldn't get items for building, waiting")
        return
      end

      puts "Starting " + @name

      @building = DFHack.building_alloc(@type, @subtype, @custom=0) # hardcode 0 for soapmaker, ignored otherwise
      if @type == :Workshop || @type == :Furnace
        DFHack.building_position(@building, @position)
      else
        DFHack.building_position(@building, @position, @width, @height)
      end


      DFHack.building_construct(@building, items)
      puts(@building)

      if (@type == :Trap and @building.jobs[0])
        @building.jobs[0].flags.do_now = true
      end

      @started = true
    end

    checkFinished()
  end

  def checkFinished()
    #puts "Checking Finished " + @name
    # if @finished
    #   return true
    # end

    findBuilding()
    if @building != nil
      if @building.flags.exists
        @started = true
        @finished = true
        # if (@jobs != nil && @jobs.length > 0)
        #   addJobs()
        # end
        finalizeBuild()
        #puts("Done checkfinished")
        return true
      else
        # unsuspend construction
        @building.jobs[0].flags.suspend = false
      end
    end
    return false
  end

  def finalizeBuild()

  end

  def addJobs()


    puts "Adding jobs"
    @jobs.each do |j|
      ref = DFHack::GeneralRefBuildingHolderst.cpp_new
      ref.building_id = @building.id

      job = df::Job.cpp_new
      # puts("+=====")
      # puts(j.inspect)
      job.job_type = j[:JobType]
      puts "Adding " + job.job_type.to_s
      # job.mat_type = j[:MatType] if j.has_key? :MatType #unless j[:MatType] == :Nil
      job.item_type = j[:ItemType] if j.has_key? :ItemType #unless j[:MatType] == :Nil
      job.item_subtype = j[:ItemSubType] if j.has_key? :ItemSubType #unless j[:MatType] == :Nil
      # job.reaction_name = j[:ReactionName] if j.has_key? :ReactionName #unless j[:MatType] == :Nil

      bSkip = false
      @building.jobs.each do |k|
        if k.job_type == job.job_type and job.item_subtype == k.item_subtype
          bSkip = true
        end
      end

      if !bSkip
        puts "bSkip is false"
        case @type
        when :Workshop
          case @subtype
          when :Kitchen
            case j[:JobType]
            when :PrepareMeal
              # PREPAREMEAL EASY
              job.mat_type = 2
              item1 = df::JobItem.cpp_new
              item1.flags1.unrotten = true
              item1.flags1.cookable = true
              item1.has_tool_use = -1
              item1.item_type = -1
              job.job_items << item1
              item2 = df::JobItem.cpp_new
              item2.flags1.unrotten = true
              item2.flags1.cookable = true
              item2.has_tool_use = -1
              item2.item_type = -1
              job.job_items << item2
            when 211 # renderfat
              job.reaction_name = "RENDER_FAT"
              item1 = df::JobItem.cpp_new
              item1.item_type = 74
              item1.reaction_class = "FAT"
              item1.has_material_reaction_product = "RENDER_MAT"
              item1.reagent_index = 0
              item1.reaction_id = 1
              item1.has_tool_use = -1
              item1.flags1.unrotten = true
              job.job_items << item1
            end
          when :Quern
            # mill plants
            item1 = df::JobItem.cpp_new
            item1.flags1.unrotten = true
            item1.flags1.millable = true
            item1.has_tool_use = -1
            item1.item_type = 53
            job.job_items << item1
          when :Masons
            job.item_subtype = -1
            job.mat_type = 0
            item1 = df::JobItem.cpp_new
            item1.item_type = 4
            item1.mat_type = 0
            item1.has_tool_use = -1
            item1.flags2.non_economic = true
            item1.flags3.hard = true
            job.job_items << item1
          when :Mechanics
            job.item_type = -1
            job.item_subtype = -1
            job.mat_type = 0
            item1 = df::JobItem.cpp_new
            item1.item_type = 4
            item1.mat_type = 0
            item1.has_tool_use = -1
            item1.flags2.non_economic = true
            item1.flags3.hard = true
            job.job_items << item1
          when :Carpenters
            # one block of wood
            job.material_category.wood = true
            item1 = df::JobItem.cpp_new
            item1.item_type = 5
            item1.has_tool_use = -1
            job.job_items << item1
          when :Craftsdwarfs
            puts "Craftsdwarfs jobtype %s" % j[:JobType].to_s
            case j[:JobType]
            when 218
              case j[:ItemSubType]
              when 12 # rock pot
                job.mat_type = 0
                item1 = df::JobItem.cpp_new
                item1.item_type = 4
                item1.mat_type = 0
                item1.has_tool_use = -1
                item1.flags2.non_economic = true
                item1.flags3.hard = true
                job.job_items << item1
              when 10 # rock nest box
                job.mat_type = 0
                item1 = df::JobItem.cpp_new
                item1.item_type = 4
                item1.mat_type = 0
                item1.has_tool_use = -1
                item1.flags2.non_economic = true
                item1.flags3.hard = true
                job.job_items << item1
              end
            when :MakeGoblet
              job.mat_type = 0
              item1 = df::JobItem.cpp_new
              item1.item_type = 4
              item1.mat_type = 0
              item1.has_tool_use = -1
              item1.flags2.non_economic = true
              item1.flags3.hard = true
              job.job_items << item1
            when :MakeCrafts
              job.mat_type = 0
              item1 = df::JobItem.cpp_new
              item1.item_type = 4
              item1.mat_type = 0
              item1.has_tool_use = -1
              item1.flags2.non_economic = true
              item1.flags3.hard = true
              job.job_items << item1
            when :MakeAmmo # bone arrows
              job.item_type = -1
              job.item_subtype = 0
              job.material_category.bone = true
              job.unk4 = 6778473
              item1 = df::JobItem.cpp_new
              item1.item_type = -1
              item1.has_tool_use = -1
              item1.flags1.unrotten = true
              item1.flags2.bone = true
              item1.flags2.body_part = true
              job.job_items << item1
            end
          when :Bowyers
            job.item_type = 5
            job.item_subtype = 6
            job.material_category.bone = true
            item1 = df::JobItem.cpp_new
            item1.item_type = -1
            item1.has_tool_use = -1
            item1.flags1.unrotten = true
            item1.flags2.body_part = true
            item1.flags2.bone = true
            job.job_items << item1
          when :Leatherworks
            job.item_type = 0
            job.item_subtype = -1
            job.material_category.leather = true
            item1 = df::JobItem.cpp_new
            item1.item_type = 54
            item1.has_tool_use = -1
            job.job_items << item1
          when :Farmers
            case j[:JobType]
            when :MakeCheese
              job.item_subtype = -1
              job.mat_type = -1
              item1 = df::JobItem.cpp_new
              item1.item_type = -1
              item1.has_tool_use = -1
              item1.flags1.unrotten = true
              item1.flags1.milk = true
              job.job_items << item1
            when :ProcessPlants
              item1 = df::JobItem.cpp_new
              item1.item_type = 53
              item1.has_tool_use = -1
              item1.flags1.unrotten = true
              item1.flags1.processable = true
              job.job_items << item1
            when 211 #PROCESS_PLANT_TO_BAG
              job.reaction_name = "PROCESS_PLANT_TO_BAG"
              item1 = df::JobItem.cpp_new
              item1.flags1.unrotten = true
              item1.flags1.cookable = true
              item1.has_tool_use = -1
              item1.item_type = -1
              job.job_items << item1
              item2 = df::JobItem.cpp_new
              item2.flags1.unrotten = true
              item2.flags1.cookable = true
              item2.has_tool_use = -1
              item2.item_type = -1
              job.job_items << item2
            when :SpinThread
              job.material_category.fiber = true
              item1 = df::JobItem.cpp_new
              item1.has_tool_use = -1
              item1.flags1.unrotten = true
              item1.flags2.body_part = true
              item1.flags2.hair_wool = true
              job.job_items << item1
            end
          when :Loom
            # weave thread into cloth
            job.material_category.plant = true
            item1 = df::JobItem.cpp_new
            item1.quantity = 15000
            item1.item_type = 56
            item1.has_tool_use = -1
            item1.flags1.collected = true
            item1.flags2.plant = true
            item1.min_dimension = 15000
            job.job_items << item1
          when :Ashery
            case j[:JobType]
            when :MakePotashFromAsh
              item1 = df::JobItem.cpp_new
              item1.item_type = 0
              item1.mat_type = 9
              item1.has_tool_use = -1
              job.job_items << item1
            when :MakeLye
              item1 = df::JobItem.cpp_new
              item1.item_type = 0
              item1.mat_type = 9
              item1.has_tool_use = -1
              job.job_items << item1
              item2 = df::JobItem.cpp_new
              item2.item_type = 18
              item2.flags1.empty = true
              item2.has_tool_use = -1
              job.job_items << item2
            end
          when :Custom # soapmakers for now
            job.reaction_name = "MAKE_SOAP_FROM_TALLOW"
            item1 = df::JobItem.cpp_new
            item1.item_type = -1
            item1.has_tool_use = -1
            item1.reagent_index = 1
            item1.reaction_id = 2
            job.job_items << item1
            item2 = df::JobItem.cpp_new
            item2.item_type = 74
            item2.quantity = 150
            item2.reaction_class = "TALLOW"
            item2.has_material_reaction_product = "SOAP_MAT"
            item2.reagent_index = 2
            item2.reaction_id = 2
            item2.flags1.unrotten = true
            item2.has_tool_use = -1
            job.job_items << item2
          when :Still
            job.reaction_name = "BREW_DRINK_FROM_PLANT"
            item1 = df::JobItem.cpp_new
            item1.item_type = 53
            item1.flags1.unrotten = true
            item1.has_tool_use = -1
            item1.has_material_reaction_product = "DRINK_MAT"
            item1.reagent_index = 0
            item1.reaction_id = 22
            job.job_items << item1
            item2 = df::JobItem.cpp_new
            item2.item_type = -1
            item2.flags1.empty = true
            item2.flags3.food_storage = true
            item2.has_tool_use = -1
            item2.reagent_index = 1
            item2.reaction_id = 22
            job.job_items << item2
          end
        when :Furnace
          case @subtype
          when :WoodFurnace # charcoal or ash
            job.item_subtype = -1
            item1 = df::JobItem.cpp_new
            item1.item_type = 5
            item1.has_tool_use = -1
            job.job_items << item1
          when :GlassFurnace
            case j[:JobType]
            when 22 # COLLECT SAND
              job.item_subtype = -1
              job.mat_type = -1
            else
              job.item_subtype = -1
              job.mat_type = 4
              item1 = df::JobItem.cpp_new
              item1.item_type = -1
              item1.has_tool_use = -1
              item1.flags1.sand_bearing = true
              job.job_items << item1
            end
          end
        end

        job.pos = [@building.centerx, @building.centery, @building.z]
        job.general_refs << ref
        job.flags.repeat = true
        job.flags.suspend = true
        @building.jobs << job
        df::job_link job

        puts "Added"
      else
        puts "Skipping"
      end
    end
  end

  def getBoulder()
    item = df.world.items.all.find { |i|
        i.kind_of?(DFHack::ItemBoulderst) and
        DFHack.item_isfree(i)
    }
    return item != nil ? [item] : false
  end

  def getTrapparts()
    item = df.world.items.all.find { |i|
        i.kind_of?(DFHack::ItemTrappartsst) and
        DFHack.item_isfree(i)
    }
    return item
  end


  def getItem(cls, subtype)
    item = df.world.items.all.find { |i|
        i.kind_of?(cls) and
        DFHack.item_isfree(i) and
        (subtype == nil or i.subtype.id.to_s == subtype)
    }
    return item
  end

  def getBuildingItems()
    case @type
    when :Trap
      return [getTrapparts()]
    when :NestBox
      return [getItem(DFHack::ItemToolst, "ITEM_TOOL_NEST_BOX")]
    when :Construction
      case @subtype
      when :Wall
        #puts("Returning for wall")
        i = getBoulder()
        puts(i)
        return i
      end
    end
    return []
  end
end

puts "Loaded class BuildTask"
