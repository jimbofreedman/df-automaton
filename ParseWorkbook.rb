
load 'Phase.rb'
load 'Task.rb'
load 'BuildTask.rb'

puts 'Parsing Workbook'

xlsx = Roo::Spreadsheet.open('/home/jimbo/df/utils/df2016.xlsx')
offset = [0, 0, 0]

$phases = Hash.new
$tasks = Array.new

def addTask(task)
  $tasks.push(task)
end

def parseFloor(name, z, sheet)
  puts("========================")
  puts("%s\t%s" % [z, name])
  puts("========================")
  y = 0
  sheet.each_row_streaming(offset: 1) do |row| #sheet.last_row) do |row|
    row.each_with_index do |cell, x|
      next if x == 0
      if (cell.value)
        x = x - 1 # because we have the numbers down the side in column A, column B is index 0
        puts("%2ix%2i\t%-20s\t%ix%i" % [x, y, cell, cell.width, cell.height])
        txt = cell.value
        deets = txt.to_s.split("/")

        if (txt[0] == "!")
          name = deets[1]
          addTask(Task.new(name, [x, y, z], [cell.width, cell.height], txt[1]))
        elsif ($building_details.include? deets[0])
          name = (deets[1] || deets[0])
          addTask(BuildTask.new(name, [x, y, z], [cell.width, cell.height], $building_details))
        end
      end
    end
    y = y + 1
  end
end

$building_details = Hash.new()
sheet_building_details = xlsx.sheet('buildingdetails')
sheet_building_details.each_row_streaming(offset: 1) do |row|
  $building_details[row[0].value] = {
    type: row[1] ? row[1].value : "",
    subtype: row[2] ? row[2].value : "",
    option1: row[3] ? row[3].value : "",
    option2: row[4] ? row[4].value : "",
    option3: row[5] ? row[5].value : ""
  }
end

puts($building_details)

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
  puts(name)
  taskNames = row[1].value.split(",")
  puts(taskNames)
  puts($tasks[0])
  phaseTasks = $tasks.select { |t| taskNames.include?(t.name) }
  $phases[name] = Phase.new(name, phaseTasks)
end

puts("=======")
puts("TASKS:")
puts("=======")
puts($tasks)
$phases.each do |n,p|
  p.print()
end
#puts(floors)
