require 'Launchy'
require 'Journey.rb'
require 'Dijkstra.rb'

# Helper method to print out help list of all available commands
def print_list_of_commands
  puts "Available commands are"
  puts "getinfo [CITY_CODE] - Provides all information about that city"
  puts "getshortest - Shortest flight"
  puts "getlongest - Longest flight"
  puts "maproutes - All the CSAir routes on a map in your browser"
  puts "getaveragedistance - Average Distance of all flights"
  puts "getbiggest - Biggest population city"
  puts "getsmallest - Smallest population city"
  puts "getaveragepop - Average population of all cities"
  puts "getcontinents - List of Cities in each Continent"
  puts "gethubs - List of all hub cities"
  puts "removecity [CITY_CODE] - Removes city from network"
  puts "removeroute [CITY_CODE_1] [CITY_CODE_2] [DIRECTION] - Removes a route from the network based on direction"
  puts "[DIRECTION] can take values - \"FORWARD\" \"BACKWARD\" \"BOTH\""
  puts "addcity [CITY_CODE] - Adds a city to the CSAir network"
  puts "addroute [CITY_CODE_1] [CITY_CODE_2] [DIRECTION] - Adds a route to the network based on direction"
  puts "writetojson - Writes the CSAir network to new json file"
  puts "journey [CITY_CODES OF ROUTE] -  Creates a journey through CSAir routes."
  puts "findjourney [CITY_CODE_1] [CITY_CODE_2] - Find shortest route between 2 cities"
  puts "addjson [FILE_NAME] - Adds a new json file to the CSAir network."
end

# Helper method to print city information
def print_city_info(code, graph_instance)
  city = graph_instance.node_hash[code]
  if(city == nil)
    puts "Not a valid city code"
  else
    puts "Name : #{city.name}"
    puts "Code : #{city.code}"
    puts "Country : #{city.country}" 
    puts "Continent : #{city.continent}" 
    puts "Timezone : #{city.timezone}"
    puts "Coordinates : #{city.coordinates}"
    puts "Population : #{city.population}"
    puts "Region : #{city.region}"
    puts "Linked Cities :\n"
    city.linked_cities.each { |route|
      puts "Distance : #{route.distance} to #{route.city}"
    }
  end
end

# Helper method for querying longest flight
def print_longest_flight(graph_instance)
  max_distance = 0
  city1 =''
  city2 =''
  graph_instance.node_hash.each_key { |key|
    linked = graph_instance.node_hash[key].linked_cities
    linked.each{ |tuple|
      if(tuple.distance > max_distance)
        max_distance = tuple.distance
        city1 = key
        city2 = tuple.city
      end
    }
  }
  puts "Longest flight is #{max_distance} between #{city1} and #{city2}"
end

# Helper method for querying shortest flight
def print_shortest_flight(graph_instance)
  min_distance = 100000
  city1 =''
  city2 =''
  graph_instance.node_hash.each_key { |key|
    linked = graph_instance.node_hash[key].linked_cities
    linked.each{ |tuple|
      if(tuple.distance < min_distance)
        min_distance = tuple.distance
        city1 = key
        city2 = tuple.city
      end
    }
  }
  puts "Shortest flight is #{min_distance} between #{city1} and #{city2}"
end

# Helper method for querying average flight distance
def print_average_distance(graph_instance)
  ave_distance = 0
  counter = 0
  graph_instance.node_hash.each_key { |key|
    linked = graph_instance.node_hash[key].linked_cities
    linked.each{ |tuple|
      ave_distance = ave_distance + tuple.distance
      counter = counter + 1
    }
  }
  ave_distance = ave_distance/counter
  puts "Average flight distance is #{ave_distance}"
end

# Helper method for querying biggest population
def print_biggest_population(graph_instance)
  max_population = 0
  city_name =''
  graph_instance.node_hash.each_key { |key|
    city = graph_instance.node_hash[key]
    if city.population > max_population
      max_population = city.population
      city_name = city.name
    end
  }
  puts "Biggest population is #{max_population} in #{city_name}"
end

# Helper method for querying smallest population
def print_smallest_population(graph_instance)
  min_population = graph_instance.node_hash['MEX'].population
  city_name =''
  graph_instance.node_hash.each_key { |key|
    city = graph_instance.node_hash[key]
    if city.population < min_population
      min_population = city.population
      city_name = city.name
    end
  }
  puts "Smallest population is #{min_population} in #{city_name}"
end

# Helper method for querying average population
def print_average_population(graph_instance)
  ave_population = 0
  graph_instance.node_hash.each_key { |key|
    city = graph_instance.node_hash[key]
    ave_population = ave_population + city.population
  }
  ave_population = ave_population/graph_instance.node_hash.length()
  puts "Average population is #{ave_population}."
end

# Helper method for querying cities grouped by continents
def print_continent_cities(graph_instance)
  graph_instance.continent_hash.each_key { |key|
    continent = graph_instance.continent_hash[key]
    puts "Cities in #{key} are - "
    continent.each { |city|
      puts "#{city}"
    }
  }
end

# Helper method for querying hub cities
def print_hub_cities(graph_instance)
  graph_instance.node_hash.each_key { |key|
    city = graph_instance.node_hash[key]
    if(city.linked_cities.size() > 5)
      puts "#{city.name} is a hub city."
    end
  }
end

# Helper method for querying and mapping all routes by CSAir
def maproutes(graph_instance)
  url ='http://www.gcmap.com/mapui?P='
  route_strings=''
  graph_instance.node_hash.each_key{ |key|
    linked = graph_instance.node_hash[key].linked_cities
    linked.each{ |tuple|
      route_strings = route_strings + "#{key}-#{tuple.city},+"
    }
  }
  Launchy.open(url+route_strings)
end

# Helper method to create a new journey along a valid path. Also gets cost, time and distance of journey.
def create_journey(input, graph_instance)
  input.delete_at(0)
  new_journey = Journey.new(input)
  if(new_journey.validate_route(graph_instance))
    new_journey.get_distance()
    new_journey.get_cost()
    new_journey.get_time()
  end
end

# Helper method to find the shortest journey between 2 cities.
def find_journey(city1, city2, graph_instance)
  distance, previous = find_shortest_journey(city1, city2, graph_instance)
  puts "Shortest distance is #{distance} with stopovers at"
  c = city2
    while(true)
      if(c == city1)
        break
      end
      puts "#{previous[c]}"
      c = previous[c]
    end
end

# Important method controlling the querying interface
def start_text_ui(graph_instance)
  while true
    input = gets
    input = input.split()
    if input[0] == "help"
      print_list_of_commands
    elsif input[0] == "getinfo"
      print_city_info(input[1], graph_instance)
    elsif input[0] == "getlongest"
      print_longest_flight(graph_instance)
    elsif input[0] == "getshortest"
      print_shortest_flight(graph_instance)
    elsif input[0] == "maproutes"
      maproutes(graph_instance)
    elsif input[0] == "getaveragedistance"
      print_average_distance(graph_instance)
    elsif input[0] == "getbiggest"
      print_biggest_population(graph_instance)
    elsif input[0] == "getsmallest"
      print_smallest_population(graph_instance)
    elsif input[0] == "getaveragepop"
      print_average_population(graph_instance)
    elsif input[0] == "getcontinents"
      print_continent_cities(graph_instance)
    elsif input[0] == "gethubs"
      print_hub_cities(graph_instance)
    elsif input[0] == "removecity"
      graph_instance.remove_city(input[1])
    elsif input[0] == "removeroute"
      graph_instance.remove_route(input[1], input[2], input[3])
    elsif input[0] == "addcity"
      graph_instance.add_city(input[1])
    elsif input[0] == "addroute"
      graph_instance.add_route(input[1], input[2], input[3])
    elsif input[0] == "writetojson"
      graph_instance.write_to_json
    elsif input[0] == "journey"
      create_journey(input, graph_instance)
    elsif input[0] == "findjourney"
      find_journey(input[1], input[2], graph_instance)  
    elsif input[0] == "addjson"
      graph_instance.add_json(input[1])
    else
      puts "INVALID INPUT"
      end
   end
end
