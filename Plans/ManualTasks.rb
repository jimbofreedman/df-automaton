$priorities = [
  "temp_meeting", # safe area for everyone to wait
  "lostandfound", # stockpile for items not stored elsewhere
  "farm3", # get started on pig tails
  "pasture12", # pastures for goats
  "nestbox12", # pastures for turkeys
  "mechanics", # traps etc.
  "carpenters", # cages, buckets etc.
  "vwall", # breach and reseal caverns
  "still1", # basic food industry
  "depot", # trade depot
  "dig_industry_3", # main cistern (start)
  "fg_in", # floodgate to stop buildingdestroyers
  "dig_surface_3", # let the river in
  "dig_entrance_3", # refuse
  "dig_pasture_9", # northern half of tree farm
  "dig_industry_10", # all non-metal / non-decoration industries
  "dig_industry_11", # metal / decoration industries
  "dig_dining_3", # dining room
  "dig_entrance_5", # barracks
]


addTask(DigTask.new("stairs-2", ["dig_pasture_6"], [25, 24, -2], "singlei.csv", "nil"))
(-9..-3).each do |z|
  addTask(DigTask.new("stairs" + z.to_s, ["stairs" + (z+1).to_s], [25, 24, z], "singlei.csv", "nil"))
end
