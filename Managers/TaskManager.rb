$LOAD_PATH.push('./hack/scripts/automaton/roo/lib')
$LOAD_PATH.push('/home/jimbo/.rvm/gems/ruby-2.3.0/extensions/x86-linux/2.3.0/nokogiri-1.6.7.2/')
require 'roo'
load 'Manager.rb'
load 'Phase.rb'
load 'Task.rb'
load 'BuildTask.rb'
load 'BuildStockpileTask.rb'

class TaskManager < Manager
  def initialize()
    puts "Initializing TaskManager"
    loadWorkbook("goive")
    puts 'Initialized TaskManager'
  end

  def loadWorkbook(filename)
    puts 'Parsing Workbook'

    xlsx = Roo::Spreadsheet.open('/home/jimbo/df/utils/df2016.xlsx')
    offset = [0, 0, 0]

    $phaseQueue = Queue.new
    $phases = Hash.new
    $tasks = Array.new

    def addTask(task)
      $tasks.push(task)
    end

    def parseFloor(name, z, sheet)
      #puts("========================")
      #puts("%s\t%s" % [z, name])
      #puts("========================")
      y = 0
      sheet.each_row_streaming(offset: 1, pad_cells: true) do |row| #sheet.last_row) do |row|
        row.each_with_index do |cell, x|
          next if x == 0
          if (cell and cell.value)
            x = x - 1 # because we have the numbers down the side in column A, column B is index 0
            #puts("%2ix%2i\t%-20s\t%ix%i" % [x, y, cell, cell.width, cell.height])
            txt = cell.value
            deets = txt.to_s.split("/")

            if (txt[0] == "!")
              name = deets[1]
              addTask(Task.new(name, [x, y, z + $offset[2]], [cell.width, cell.height], txt[1]))
            elsif ($building_details.include? deets[0])
              details = $building_details[deets[0]]
              name = (deets[1] || deets[0])
              case details[:type]
              when :Stockpile
                addTask(BuildStockpileTask.new(name, [x, y, z + $offset[2]], [cell.width, cell.height], $building_details[deets[0]]))
              else
                addTask(BuildTask.new(name, [x, y, z + $offset[2]], [cell.width, cell.height], $building_details[deets[0]]))
              end
            end
          end
        end
        y = y + 1
      end
    end

    $building_details = Hash.new()
    sheet_building_details = xlsx.sheet('buildingdetails')
    sheet_building_details.each_row_streaming(offset: 1, pad_cells: true) do |row|
      $building_details[row[0].value] = {
        type: row[1] ? row[1].value.to_sym : nil,
        subtype: row[2] ? row[2].value.to_sym : nil,
        option1: row[3] ? row[3].value : "",
        option2: row[4] ? row[4].value : "",
        option3: row[5] ? row[5].value : ""
      }
    end

    #puts($building_details)

    floors = Hash.new
    sheet_floors = xlsx.sheet('floordetails')
    sheet_floors.each_row_streaming(offset: 1) do |row|
      if (row[0].value and row[1].value and (!row[2] or row[2].value != "disabled"))
        floors[row[0].value] = row[1].value
        parseFloor(row[1].value, row[0].value, xlsx.sheet(row[1].value))
      end
    end

    phase_floors = xlsx.sheet('phases')
    phase_floors.each_row_streaming(offset: 1) do |row|
      name = row[0].value
      #puts(name)
      taskNames = row[1].value.split(",")
      #puts(taskNames)
      #puts($tasks[0])
      phaseTasks = $tasks.select { |t| taskNames.include?(t.name) }
      $phases[name] = Phase.new(name, phaseTasks)
      $phaseQueue.push($phases[name])
    end

    $tasks.each do |t|
      t.digCheckFinished()
      t.checkFinished()
    end
  end

  def process()
    while (!$phaseQueue.empty? and (@currentPhase == nil or @currentPhase.checkFinished()))
      @currentPhase = $phaseQueue.pop()
    end

    if (@currentPhase.checkFinished())
      status()
      puts("AUTOMATON HAS FINISHED")
      df.pause_state = true
    end
    
    @currentPhase.print()
    @currentPhase.tasks.each do |t|
      t.digCheckFinished() if t.digStarted and !t.digFinished
      t.digStart() if !t.digStarted
      t.checkFinished() if t.started and !t.finished
      t.start() if !t.started
    end
    @currentPhase.print()
  end

  def status()
    $phases.each do |n,p|
      p.print()
    end
  end
end

puts "Loaded class TaskManager"
