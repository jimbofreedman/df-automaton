$nextPod = 0

class StockPod < Pod
  attr_reader :settingsFile

  def initialize(name, podX, podY, podZ, deps, settingsFile)
    @name = $nextPod.to_s.rjust(3, "0") + ":pod:" + name
    $nextPod = $nextPod + 1
    @x = 3 + (podX * 8)
    @y = 3 + (podY * 8)
    @z = -podZ
    @podX = podX
    @podY = podY
    @podZ = podZ
    @depNames = deps
    @deps = []
    @digDeps
    @priority = 0
    @overriden = false

    @started = false
    @finished = false

    @dig_task = DigTask.new(name + "_dig", deps, [x, y, z], "pod.csv", :Nil)

    $pods[name] = self

    @settingsFile = settingsFile
    if ($podCoords[podZ][podX][podY] != nil)
      puts "ERROR: pod %s already at %i,%i,%i so can't insert %s" % [$podCoords[podZ][podX][podY], podZ, podX, podY, name]
    else
      $podCoords[podZ][podX][podY] = self
    end
  end

  def postFinish()
    task = BuildStockpileTask(@origName, [], [@x, @y, @z], 7, 7, @settingsFile)
  end
end
