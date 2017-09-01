$nextPod = 0

class Pod
  attr_reader :podX, :podY, :podZ, :x, :y, :z, :name, :deps, :digDeps, :digTask, :priority, :overriden, :started, :digFinished, :finished, :origName, :tasks

  def initialize(name, podX, podY, podZ, deps)
    @origName = name
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
    @digFinished = false

    @dig_task = DigTask.new(name + "_dig", deps, [x, y, z], "pod.csv", :Nil)
    @tasks = Hash.new

    $pods[name] = self
    if ($podCoords[podZ][podX][podY] != nil)
      puts "ERROR: pod %s already at %i,%i,%i so can't insert %s" % [$podCoords[podZ][podX][podY], podZ, podX, podY, name]
    else
      $podCoords[podZ][podX][podY] = self
    end
  end

  def addTask(task)
    task.position[0] = task.position[0] + x
    task.position[1] = task.position[1] + y
    task.position[2] = task.position[2] + z
    @tasks[task.name] = task
  end

  def print()
    puts("%s%s%s %5i %6s %1i %1i %1i %s" % [started ? "S" : " ", digFinished ? "D" : " ", finished ? "F" : " ", priority, overriden.to_s, podZ, podX, podY, name])
  end

  def startSetPriority(priority)
    if (priority >= (@priority || 0))
      @priority = priority
      @deps.each do |d|
        d.setPriority(priority+1)
      end
    end
  end

  def setPriority(priority)
    if (priority >= (@priority || 0))
      @overriden = true
      @priority = priority
      @deps.each do |d|
        puts(d.name)
        d.setPriority(priority+1)
      end
    end
  end

  def setDependencies()
    @depNames.each do |n|
      @deps << $pods[n]
    end
  end

  def getDigDependency()
    if (@podX > 0)
      p = $podCoords[@podZ][@podX-1][@podY]
      if (p == nil)
        puts("ERROR: Couldn't get x- digdep at %i %i %i from %i %i %i" % [@podZ, @podX-1, @podY, @podZ, @podX, @podY])
      end
      digDep = p.getDigDependency()
    elsif (@podY < 4)
      p = $podCoords[@podZ][@podX][@podY+1]
      if (p == nil)
        puts("ERROR: Couldn't get y+ digdep at %i %i %i from %i %i %i" % [@podZ, @podX, @podY+1, @podZ, @podX, @podY])
      end
      digDep = p.getDigDependency()
    elsif (@podZ > 0)
      p = $podCoords[@podZ-1][@podX][@podY]
      if (p == nil)
        puts("ERROR: Couldn't get z- digdep at %i %i %i from %i %i %i" % [@podZ-1, @podX, @podY, @podZ, @podX, @podY])
      end
      digDep = p.getDigDependency()
    else
      #puts("selfy" + @name)
      digDep = self
      #puts(digDep.name)
      #puts("=======")
    end

    return digDep.digFinished ? self : digDep
  end

  def start()
    @started = true
    @dig_task.start()
  end

  def checkDigFinished()
    if @digFinished
      return true
    else
      @digFinished = @dig_task.checkFinished()
      if @digFinished
        @started = true
        buildPhase()
      end
      return @digFinished
    end
  end

  def checkFinished(force)
    force = force || false
    if !force && @finished
      return true
    else
      @finished = tasks.all? do |n,t| t.checkFinished end
      return @finished
    end
  end

  def buildPhase()
    @tasks.each do |n,t|
      t.start()
    end
  end
end

puts "Loaded class Pod"
