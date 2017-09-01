class PastureManager < Manager
  def initialize()
    puts "Initializing PastureManager"

    @pastures = Hash.new
    @units = Array.new

    @lastPop = 0
  end

  def process()
    #puts "Checking pastures"
    @units = df.world.units.all.select { |u| u.race != 522 && u.civ_id == 87 }

    pop = @units.length

    if (pop != @lastPop)
      puts "Pasture population has changed, was %i, now %i" % [@lastPop, pop]
      @lastPop = pop
      doProcess()
    end
  end

  def doProcess()
    pop = @lastPop

    @units = df.world.units.all.select { |u| u.race != 522 && u.civ_id == 87 }
    @units.each do |u|
      u.flags2.slaughter = true
    end

    processSpecies(165, 16) # goats
    processSpecies(158, 48) # cats
    processSpecies(177, 1) # turkeys
    processSpecies(157, 1) # dogs
  end

  def processSpecies(race, sizeReq)
    #puts("Processing " + race.to_s)
    goats = @units.select {|g| g.race == race}

    ps = @pastures[race]

    # if we have no pastures, we aren't set up yet, so don't slaughter
    if (ps == nil)
      #puts("No pastures for " + race.to_s)
      goats.each {|g| g.flags2.slaughter = false}
      return
    end

    allowed = 0
    ps.each do |p|
      if (p.x1 < 1000 && p.y1 < 1000 && p.x2 < 1000 && p.y2 < 1000 &&
          p.x1 > 0 && p.y1 > 0 && p.x2 > 0 && p.y2 > 0) # todo memory issues
        size = ((1+p.x2-p.x1) * (1+p.y2-p.y1))
        #puts(size)
        allowed = allowed + (size / sizeReq)
      else
        ps.remove(p)
        #@pastures[race].remove(p)
      end
    end
    #puts(allowed)

    goats.sort! { |a,b|
      if (a.profession != b.profession)
        (a.profession == :STANDARD) ? -1 : 1
      elsif (a.sex != b.sex)
        (a.sex == 1) ? -1 : 1
      elsif (a.relations.birth_year != b.relations.birth_year)
        a.relations.birth_year - b.relations.birth_year
      else
        a.relations.birth_time - b.relations.birth_time
      end
    }

    #puts(allowed)
    total_spots = 4
    adult_male_spots = 2
    young_male_spots = 0
    adult_female_spots = 2
    young_female_spots = 0
    if (allowed > 4)
      total_spots = allowed
      male_spots = [allowed / 2, 3].min
      adult_male_spots = 2
      young_male_spots = male_spots - adult_male_spots
      female_spots = [allowed - male_spots, 3].max
      adult_female_spots = [female_spots, 3].max
      young_female_spots = [female_spots - adult_female_spots, 1].max
    end

    #puts "%i %i %i %i %i" % [total_spots, adult_male_spots, young_male_spots, adult_female_spots, young_female_spots]

    keepers = Array.new()
    keepers = keepers + goats.select { |g| g.profession == :STANDARD && g.sex == 1 }.take(adult_male_spots) # take adult males
    #puts keepers.length.to_s
    keepers = keepers + goats.select { |g| g.profession != :STANDARD && g.sex == 1 }.take(young_male_spots) # take young males
    #puts keepers.length.to_s
    keepers = keepers + goats.select { |g| g.profession == :STANDARD && g.sex == 0 }.take(adult_female_spots) # take adult females
    #puts keepers.length.to_s
    keepers = keepers + goats.select { |g| g.profession != :STANDARD && g.sex == 0 }.take(young_female_spots) # take young females
    #puts keepers.length.to_s

    if (keepers.length < total_spots)
      #puts "We still have space"
      # take females then males, in age order
      keepers = keepers + goats.select { |g| !keepers.include?(g) }.take(total_spots - keepers.length)
    end

    keepers.each do |u|
      #puts "%i %i %i %i" % [u.profession, u.sex, u.relations.birth_year, u.relations.birth_time]
      u.flags2.slaughter = false
    end

    ps.each do |p|
      p.assigned_units.clear()
    end

    lastLength = nil
    while (keepers.length > 0 && keepers.length != lastLength)
      lastLength = keepers.length
      ps.each do |p|
        ref = DFHack::GeneralRefBuildingCivzoneAssignedst.cpp_new
        ref.building_id = p.id

        w = (((1+p.x2-p.x1) * (1+p.y2-p.y1)) / sizeReq)
        #puts("%s %i/%i" % [p.name, p.assigned_units.length, w])
        if (p.assigned_units.length > w)
          #puts("Skipping")
          next
        end

        #puts "%s can take %i" % [p.name, w]
        u = keepers.pop()
        if (u != nil)
          p.assigned_units << u.id
          u.general_refs.clear()
          u.general_refs << ref
          #puts "assigning %i to %s" % [u.id, p.name]
        end
      end
    end
  end

  def registerPasture(pasture, race)
    if (@pastures[race] == nil)
      @pastures[race] = Array.new
    end

    if (!@pastures[race].include? pasture)
      @pastures[race] << pasture
    end

    #puts "Added pasture %s to race %i" % [pasture.name, race]
    doProcess()
  end

  def status()
    puts "Pasture Status:"
    @pastures.each do |race, ps|
      puts race.to_s
      ps.each do |pasture|
        puts pasture.name
      end
    end
  end
end

puts "Loaded class PastureManager"
