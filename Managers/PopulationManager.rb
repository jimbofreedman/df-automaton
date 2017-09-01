class PopulationManager < Manager
  def initialize()
    puts "Initializing PopulationManager"

    @lastPop = 0


  end

  def process()
    #puts "Checking pastures"
    @units = df.world.units.all.select { |u| u.race == 522 && u.civ_id == 87 }

    pop = @units.length

    if (pop != @lastPop)
      puts "Population has changed, was %i, now %i" % [@lastPop, pop]
      @lastPop = pop
      doProcess()
    end
  end

  def setHauler(unit)
    unit.status.labors[:HAUL_STONE] = true
    unit.status.labors[:HAUL_WOOD] = true
    unit.status.labors[:HAUL_BODY] = true
    unit.status.labors[:HAUL_FOOD] = true
    unit.status.labors[:HAUL_REFUSE] = true
    unit.status.labors[:HAUL_ITEM] = true
    unit.status.labors[:HAUL_FURNITURE] = true
    unit.status.labors[:HAUL_ANIMALS] = true
  end

  def setGeneralist(unit)
    unit.status.labors[:HAUL_ANIMALS] = true
    unit.status.labors[:CARPENTER] = true
    unit.status.labors[:MECHANIC] = true
    unit.status.labors[:ARCHITECT] = true
    unit.status.labors[:MASON] = true
    unit.status.labors[:BREWER] = true
    unit.status.labors[:COOK] = true
    unit.status.labors[:MAKE_CHEESE] = true
    unit.status.labors[:MILK] = true
    unit.status.labors[:BUILD_CONSTRUCTION] = true
  end

  def doProcess()
    pop = @lastPop

    #df.pause_state = true

    #df.debug_fastmining = true
    #df.debug_turbospeed = true
    df.standing_orders_auto_loom = 1
    df.standing_orders_use_dyed_cloth = 1
    df.standing_orders_zoneonly_fish = 1
    df.standing_orders_zoneonly_drink = 1

    if pop > 7
      df.dfhack_run "autolabor enable"
      df.dfhack_run "autolabor MINE 3 10 3"
      df.dfhack_run "autolabor STONE_CRAFT 1 3 1"
      df.dfhack_run "autolabor MASON 7"
      df.dfhack_run "autolabor HUNT 0 0 0"
      df.dfhack_run "autolabor FISH 0 3 0"
    else
      df.dfhack_run "autolabor disable"
      laborPool = Array.new
      @units.each do |u|
        puts(u.name.first_name)
        puts(u.status.labors)
        for i in (0..u.status.labors.length-1)
          # skip mining and woodcutting, leave as is
          u.status.labors[i] = false
        end

        # if we aren't a miner, add us to the labor pool, else enable mining
        if (u.profession == :MINER)
          u.status.labors[:MINE] = true
          u.status.labors[:DETAIL] = true
        else
          laborPool.push(u)
        end

        # if we're a woodcutter re-enable that
        if (u.profession == :WOODCUTTER or u.profession2 == :WOODCUTTER)
          u.status.labors[:CUTWOOD] = true
        end
      end

      # for the labor pool, have a hauler, two beginner generalist crafters and one full-time stonecrafter
      setHauler(laborPool[0])
      setGeneralist(laborPool[1])
      setGeneralist(laborPool[2])
      laborPool[3].status.labors[:STONE_CRAFT] = true
      laborPool[3].status.labors[:HAUL_STONE] = true

      puts("+=======++")
      laborPool.each do |u|
        puts(u.name.first_name)
      end
    end


    df.dfhack_run 'keybinding add Ctrl-W@dwarfmode/QueryBuilding/Some "gui/workflow"'

    # stone
    df.dfhack_run "workflow amount TRAPPARTS//INORGANIC 10 2"
    df.dfhack_run "workflow amount TOOL:ITEM_TOOL_NEST_BOX//INORGANIC 2 1"
    df.dfhack_run "workflow amount BLOCKS//INORGANIC 10 2"
    df.dfhack_run "workflow amount COFFIN//INORGANIC 4 2"
    df.dfhack_run "workflow amount SLAB//INORGANIC 4 2"
    df.dfhack_run "workflow amount WEAPONRACK//INORGANIC 4 2"
    df.dfhack_run "workflow amount ARMORSTAND//INORGANIC 4 2"
    df.dfhack_run "workflow amount TOOL:ITEM_TOOL_LARGE_POT//INORGANIC 50 5" # 50
    df.dfhack_run "workflow amount QUERN//INORGANIC 2 1"
    df.dfhack_run "workflow amount DOOR//INORGANIC 2 1"
    df.dfhack_run "workflow amount TABLE//INORGANIC 4 2"
    df.dfhack_run "workflow amount CHAIR//INORGANIC 8 2"
    df.dfhack_run "workflow amount BOX//INORGANIC 4 2"
    df.dfhack_run "workflow amount CABINET//INORGANIC 4 2"
    # goblets are pop dependent
    df.dfhack_run "workflow amount CRAFTS//INORGANIC 10000 100"

    # wood
    df.dfhack_run "workflow amount BIN/WOOD 8 2"
    df.dfhack_run "workflow amount BED/WOOD 4 2"
    df.dfhack_run "workflow amount CAGE/WOOD 4 2"
    df.dfhack_run "workflow amount BUCKET/WOOD 8 2"
    df.dfhack_run "workflow amount SPLINT/WOOD 8 2"
    df.dfhack_run "workflow amount CRUTCH/WOOD 8 2"

    df.dfhack_run "autolabor haulpct %i" % ((pop > 12) ? 33 : 12)

    # food
    df.dfhack_run "workflow amount FOOD %i 10" % (pop * 16) # kitchen - prepare meal - 2yr supply
    df.dfhack_run "workflow amount POWDER_MISC/PLANT 10 5" # ??
    df.dfhack_run "workflow amount LIQUID_MISC/MILK 1 1" # fw - milk creature
    df.dfhack_run "workflow amount CHEESE 50 5" # fw - make cheese
    df.dfhack_run "workflow amount DRINK %i 10" % (pop * 32) # still - brew drink - 2yr supply
    df.dfhack_run "workflow amount GLOB 10 1" # kitchen - render fat
    df.dfhack_run "workflow amount BAR//ASH 3 1" # wf - make ash
    df.dfhack_run "workflow amount BAR//POTASH 10 1" # ashery - make potash
    df.dfhack_run "workflow amount LIQUID_MISC//LYE 3 1" # ashery - make lye
    df.dfhack_run "workflow amount BAR/SOAP %i 1" % (pop) # soapmaker - make soap - 1 per dwarf

    num_archers = 0 + 10 # have enough archery kit for archers + 10
    num_swords = 0 + 10 # have enough archery kit for archers + 10
    num_hammers = 0 + 10 # have enough archery kit for archers + 10
    num_military = num_archers + num_swords + num_hammers - 20 # (to cover the +10s, messy)

    # bone
    df.dfhack_run "workflow amount AMMO:ITEM_AMMO_BOLTS/BONE 5000 10" # crafts - make bone bolts
    df.dfhack_run "workflow amount WEAPON:ITEM_WEAPON_CROSSBOW/BONE %i 1" % num_archers # bowyers - make bone crossbow

    # pending: siege stuff
    # # charcoal
    #df.dfhack_run "workflow amount BAR//COAL 28 4" # 70

    # stone
    df.dfhack_run "workflow amount GOBLET//INORGANIC %i 2" % (pop * 2) # 2 cups for every dwarf

    #
    # # leather
    df.dfhack_run "workflow amount BOX/LEATHER 2 1"
    df.dfhack_run "workflow amount FLASK/LEATHER %i 1" % num_military
    df.dfhack_run "workflow amount QUIVER/LEATHER %i 1" % num_archers
    df.dfhack_run "workflow amount BACKPACK/LEATHER %i 1" % num_military

    # cloth
    # jobs:
    df.dfhack_run "workflow amount THREAD/PLANT 100 5"
  end

  def status()
    puts "Population Status"
  end
end

puts "Loaded class PopulationManager"
