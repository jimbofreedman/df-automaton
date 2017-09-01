# #$tasks["all"] = BuildStockpileTask.new("all", [], [0, 0, 0], 10, 10, "all") # surface 144
# $tasks["ramp0"] = DigTask.new("ramp0", [], [44, 4, 0], "3ramp", :Nil) # surface 144
# $tasks["ramp1"] = DigTask.new("ramp1", ["ramp0"], [44, 5, -1], "3ramp", :Nil) # riverbed 143
# $tasks["ramp2"] = DigTask.new("ramp2", ["ramp1"], [44, 6, -2], "3ramp", :Nil) # farms 142
# $tasks["ramp3"] = DigTask.new("ramp3", ["ramp2"], [44, 7, -3], "3ramp", :Nil) # upper industry 141
# $tasks["ramp4"] = DigTask.new("ramp4", ["ramp3"], [44, 8, -4], "3ramp", :Nil) # lower industry 140
# $tasks["entrance1"] = DigTask.new("entrance1", ["ramp4"], [1, 1, -5], "entrance.csv", "1") # entrance 139
#
# (-10..-2).each do |e|
#   registerDigStairs(e)
# end
#
# registerDigTask("cl", ["cl_dig_-3"], -2, "pasture.csv")
# registerDigTask("fd", ["fd_dig_-3"], -2, "pasture.csv")
# registerDigTask("dr", ["dr_dig_-3"], -2, "pasture.csv")
#
# registerDigTask("dr", ["dr_dig_-4"], -3, "industry_top.csv")
# registerDigTask("bo", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("st", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("mt", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("gl", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("fd", ["fd_dig_-4"], -3, "industry_top.csv")
# registerDigTask("wo", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("cl", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("so", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("le", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("pa", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("ch", ["stairs_-3"], -3, "industry_top.csv")
# registerDigTask("st", ["stairs_-3"], -3, "industry_top.csv")
#
# registerDigTask("cl", ["cl_dig_-3"], -4, "industry_bottom.csv")
# registerDigTask("fd", ["stairs_-4"], -4, "industry_bottom.csv")
# registerDigTask("dr", ["stairs_-4"], -4, "industry_bottom.csv")
# registerDigTask("mt", ["mt_dig_-3"], -4, "industry_bottom.csv")
# registerDigTask("gm", ["stairs_-4"], -4, "industry_bottom.csv")
#
# registerGoal("prio_food_farm", ["fd_farm1", "fd_farm2", "fd_farm3", "fd_farm4"], 10000)
# registerGoal("prio_food_cook", ["fd_kitchen1", "fd_kitchen2"], 9900)
# registerGoal("prio_booze", ["dr_still1", "dr_still2", "dr_still3", "dr_still4"], 9800)
# registerGoal("prio_wood", ["wo_dig_-3"], 9700)
