class LinkLeverTask < Task
  attr_reader :lever, :target

  def initialize(name, dependencies, leverTaskName, targetTaskName)
    @name = name
    @started = false
    @finished = false

    @stringDependencies = dependencies
    @stringDependencies.push(leverTaskName)
    @stringDependencies.push(targetTaskName)

    @leverTaskName = leverTaskName
    @targetTaskName = targetTaskName
  end

  def start()
    puts "Starting " + @name

    leverBuilding = $tasks[@leverTaskName].building
    puts @targetTaskName
    targetBuilding = $tasks[@targetTaskName].building

    if (leverBuilding.jobs.length > 0 && leverBuilding.jobs.find { |j| j.general_refs[0].building_id = targetBuilding.id })
      return
    end

    ref = DFHack::GeneralRefBuildingTriggertargetst.cpp_new
    ref.building_id = targetBuilding.id
    ref2 = DFHack::GeneralRefBuildingHolderst.cpp_new
    ref2.building_id = leverBuilding.id

    job = df::Job.cpp_new
    job.job_type = :LinkBuildingToTrigger
    job.item_type = -1
    puts "Adding " + job.job_type.to_s

    job.general_refs << ref
    job.general_refs << ref2

    item1 = getMechanism([])
    item2 = getMechanism([item1])

    if (item1 && item2)
      iref = DFHack::JobItemRef.cpp_new
      iref.item = item1
      iref.role = 3
      iref.is_fetching = 0
      iref.job_item_idx = 0

      iref2 = DFHack::JobItemRef.cpp_new
      iref2.item = item2
      iref2.role = 4
      iref2.is_fetching = 0
      iref2.job_item_idx = 0

      job.items << iref
      job.items << iref2
      leverBuilding.jobs << job
      df::job_link job
    else
      puts("Couldn't find mechanisms")
    end

    checkFinished()
  end

  def getMechanism(exclude)
    item = df.world.items.all.find { |i|
        i.kind_of?(DFHack::ItemTrappartsst) and
        !exclude.include?(i) and
        DFHack.item_isfree(i)
    }
    return item
  end

  def checkFinished()
    puts "Checking Finished " + @name
    return true
  end
end

puts "Loaded class LinkLeverTask"
