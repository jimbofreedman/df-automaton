
def digPod(pos)
  dig_name = $next_pod + "_dig"
  $tasks[dig_name] = DigTask.new(dig_name, deps, [x, y, z], "pod.csv", :Nil)
  return dig_name
end


#def blank

# def foodOut(pod_name, podX, podY, z, deps)
#   x = $offset[0] + 3 + (podX * 8)
#   y = $offset[1] + 3 + (podY * 8)
#   pod_name = $next_pod + pod_name
#
#   dig_name = digPod([x, y, z])
#   BuildStockpileTask.new(pod_name + "_stock", [dig_name], [x+1, x+2, z], 7, 7, 'food_out')
#   return dig_name
# end
