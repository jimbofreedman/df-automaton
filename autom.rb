def ain(path)
  $LOAD_PATH.push path if !$LOAD_PATH.include? path
end

ain('~/df/df_linux/hack/scripts/automaton/roo/lib/')
ain('~/.rvm/gems/ruby-2.3.0/extensions/x86-linux/2.3.0/nokogiri-1.6.7.2/')
ain('~/.rvm/gems/ruby-2.3.0/extensions/x86-linux/2.3.0/nokogiri-1.6.7.2/nokogiri')
ain('~/.rvm/gems/ruby-2.3.0/gems/rubyzip-1.2.0/lib')
ain('~/.rvm/gems/ruby-2.3.0/gems/nokogiri-1.6.7.2/lib/')
ain('~/.rvm/gems/ruby-2.3.0/gems/nokogiri-1.6.7.2/lib/nokogiri/')
ain('hack/scripts/automaton')
require 'nokogiri'
require 'nokogiri/xml'
require 'roo'

$offset = [0, 0, 168]

# def loadscripts
#   Dir["hack/scripts/automaton/*.rb"].each {|file| load file }
#   Dir["hack/scripts/automaton/Tasks/*.rb"].each {|file| load file }
#   Dir["hack/scripts/automaton/Pods/*.rb"].each {|file| load file }
   Dir["hack/scripts/automaton/Managers/*.rb"].each {|file| load file }
#   #Dir["hack/scripts/automaton/Plans/*.rb"].each {|file| load file }
# end
# loadscripts()

class Automaton
  attr_accessor :running, :taskManager, :pastureManager, :populationManager, :announcementManager

  def initialize
    @taskManager = TaskManager.new()
    #@pastureManager = PastureManager.new()
    @populationManager = PopulationManager.new()
    @announcementManager = AnnouncementManager.new()
  end

  def process
    @taskManager.process()
    #@pastureManager.process()
    @populationManager.process()
    @announcementManager.process()
  end

  def start
    @running = true
    @onupdate = df.onupdate_register('automaton', 1200) { process if @running }

    df.onstatechange_register_once { |st|
        case st
        when :WORLD_UNLOADED
            puts 'AI: world unloaded, disabling self'
            stop()
            true
        else
            $Automaton.announcementManager.statechanged(st)
            false
        end
    }
  end

  def stop
    @running = false
    if (@onupdate != nil)
      df.onupdate_unregister(@onupdate)
    end
  end

  def status
    $tasks.sort_by { |k, v| -(v.priority || 0) }.each do |n,t|
      t.print
    end
  end
end

def status()
  $Automaton.status()
end

def setHotkey(i, name)
  df.ui.main.hotkeys[i].cmd = 0
  df.ui.main.hotkeys[i].name = name
  df.ui.main.hotkeys[i].x = 0
  df.ui.main.hotkeys[i].y = 0
  df.ui.main.hotkeys[i].z = $offset[2] - i
end

def chopTrees(z)
  df.each_tree() { |t|
    if (t.pos.z == $offset[2]-z)
      if (z != 0 || t.pos.y < 34) # hack for top level of current map
        #puts(t.inspect)
        tile = df.map_tile_at(t.pos)
        tile.dig(:Default)
      end
    end
  }
end

$Automaton ||= Automaton.new

def aload()
  $Automaton ||= Automaton.new
  $tasks = Hash.new
  $currentDigTask = nil

  #load("hack/scripts/automaton/GeneratePods.rb")

  wagon = df.world.buildings.all[0]
  if (wagon.class.to_s == "DFHack::BuildingWagonst")
    DFHack.building_deconstruct(wagon)
  end

  chopTrees(0)
  setHotkey(0, "Surface")
  setHotkey(1, "Farms")
  setHotkey(2, "Industry")
  setHotkey(3, "Entrance")
  setHotkey(4, "Dining")
  setHotkey(5, "Accom1")
  setHotkey(6, "Accom2")
  setHotkey(7, "Blank1")
  setHotkey(8, "Blank2")



  load("hack/scripts/automaton/Plans/IndustryTasks.rb")
  load("hack/scripts/automaton/Plans/ManualTasks.rb")

  $tasks.each do |t|
    t[1].checkFinished()
    t[1].linkDependencies()
  end

  #puts $tasks

  prioVal = 99900
  $priorities.each do |prio|
    #puts("%20s %5i" % [prio, prioVal])
    if ($tasks[prio] == nil)
      raise "Task %s does not exist" % prio
    end

    $tasks[prio].setPriority(prioVal)
    prioVal = prioVal - 100
  end

  status()
end



def getMechanism(exclude)
  item = df.world.items.all.find { |i|
      i.kind_of?(DFHack::ItemTrappartsst) and
      !exclude.include?(i) and
      DFHack.item_isfree(i)
  }
  puts(item)
  puts(item.id)
  return item
end


def start()
  $Automaton ||= Automaton.new
  $Automaton.start
end

case $script_args[0]
when 'reload'
  aload()

when 'start'
  aload()
  start()

when 'reset'
  if ($Automaton)
    $Automaton.stop
  end
  $phases = Hash.new
  $tasks = Array.new
  $Automaton = Automaton.new

  chopTrees(0)
  setHotkey(0, "Surface")
  setHotkey(1, "Farms")
  setHotkey(2, "Industry")
  setHotkey(3, "Entrance")
  setHotkey(4, "Dining")
  setHotkey(5, "Accom1")
  setHotkey(6, "Accom2")
  setHotkey(7, "Blank1")
  setHotkey(8, "Blank2")

  start()

when 'once'
  reload()
  $Automaton.process()

when 'status'
  status()

when 'pods'
  case $script_args[2]
  when 'start'
    $pods.each do |n,p|
      if (n == $script_args[1])
        p.start()
        p.checkFinished(true)
      end
    end
  end

when 'task'
  case $script_args[1]
  when 'status'
    $Automaton.taskManager.status
  when 'load'
    $Automaton.taskManager.loadWorkbook("a")
  when 'process'
    $Automaton.taskManager.process
  end

when 'pasture'
  case $script_args[1]
  when 'status'
    $Automaton.pastureManager.status
  when 'process'
    $Automaton.pastureManager.doProcess
  end

when 'population'
  case $script_args[1]
  when 'status'
    $Automaton.populationManager.status
  when 'process'
    $Automaton.populationManager.doProcess
  end

when 'announcement'
  case $script_args[1]
  when 'status'
    $Automaton.announcementManager.status
  when 'process'
    $Automaton.announcementManager.doProcess
  end


when 'map'
  $podCoords.each do |z|
    z.each do |x|
      x.each do |y|
        if (y != nil)
          y.print()
        else
          puts("empty")
        end
      end
      puts("-----")
    end
    puts("=====")
  end


when 'setup'
  setup()

when 'test'
  ref = DFHack::GeneralRefBuildingHolderst.cpp_new
  building = df.world.selected_building
  ref.building_id = building.id

  job = df::Job.cpp_new
  # puts("+=====")
  # puts(j.inspect)
  job.job_type = 211
  puts "Adding " + job.job_type.to_s
  # job.mat_type = j[:MatType] if j.has_key? :MatType #unless j[:MatType] == :Nil
  #job.item_type = j[:ItemType] if j.has_key? :ItemType #unless j[:MatType] == :Nil
  #job.item_subtype = j[:ItemSubType] if j.has_key? :ItemSubType #unless j[:MatType] == :Nil
  # job.reaction_name = j[:ReactionName] if j.has_key? :ReactionName #unless j[:MatType] == :Nil
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
  item2.flags1.empty = true
  item2.flags3.food_storage = true
  item2.has_tool_use = -1
  item2.reagent_index = 1
  item2.reaction_id = 22
  job.job_items << item2
  job.pos = [building.centerx,  building.centery, building.z]
  job.general_refs << ref
  job.flags.repeat = true
  job.flags.suspend = true
  building.jobs << job
  df::job_link job


when 'checktask'
  $tasks.each do |e|
    if e[0] == $script_args[1]
      e[1].checkFinished()
    end
  end

when 'debugon'
  $tasks.each do |e|
    if e[0] == $script_args[1]
      e[1].debugging = true
    end
  end

when 'debugoff'
  $tasks[$script_args[1]] = false

when 'end', 'stop'
    $Automaton.stop
else
    puts $Automaton && $Automaton.running ? 'Running.' : 'Stopped.'
end
