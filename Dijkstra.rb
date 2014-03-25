require 'pri_queue.rb'

# Script implementing the Dijkstra's algorithm.
def find_shortest_journey(city1, city2, graph_instance)
  distances = {}
  previous = {}
  queue = Priqueue.new
  graph_instance.node_hash.each_key{ |key|
    distances[key] = 1.0/0.0
    previous[key] = ""
  }
  distances[city1] = 0
  graph_instance.node_hash.each_key{ |key|
    queue.push(key, distances[key])
  }
  while(true)
    node = queue.pop()
    if(node.distance == 1.0/0.0)
      break
    end
    if(node.city == city2)
      break
    end
    linked = graph_instance.node_hash[node.city].linked_cities
    linked.each{ |tuple|
    total_distance = distances[node.city] + tuple.distance
    if(total_distance < distances[tuple.city])
      distances[tuple.city] = total_distance
      previous[tuple.city] = node.city
      queue.push(tuple.city, total_distance)
    end
    }
  end
  return distances[city2], previous
end