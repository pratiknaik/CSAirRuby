require 'rubygems'
require 'json'
require 'pp'
require 'active_support/all'
require 'Node.rb'
require 'ostruct'

# Main class of the CSAir specific graph data structure.
class Graph
  
  # Method which initializes a Graph object instance. 
  # @param - map_data Taking in a json map-data of the Air routes.
  def initialize(map_data)
    @map_data = map_data
    @node_hash = {}
    @continent_hash = Hash.new{|h,k| h[k] = []}
    @routes_hash = {}
  end
  attr_reader :json_obj , :node_array, :node_hash, :continent_hash, :routes_hash, :map_data
  
  # Helper method which parses a json file and returns hashed json object
  # @return - hashed json object
  def parse_json_file(json_file)
    json = File.read(json_file)
    obj = JSON.parse(json)
    return obj
  end
  
  # Helper function which iterates through all cities in json hash and stores them
  # in a hash called node_hash for easy access. Uses Node class for creating cities.
  def store_all_cities(json_obj)
    cities = json_obj['metros'].each{ |city|
      timezone = city['timezone']
      country = city['country']
      name = city['name']
      code = city['code']
      population = city['population']
      continent = city['continent']
      coordinates = city['coordinates']
      region = city['region']
      linked_cities = []
      new_node = Node.new(code,name,country,continent,timezone,coordinates,population,region, linked_cities)
      node_hash[code] = new_node
      continent_hash[continent] << name
    }
  end
  
  # Helper function which iterates through all routes in json hash and stores them
  # as tuples in node's linked cities. Each node has it's neighboring nodes stored.
  # Also adds routes to global routes list. 
  def store_all_routes(json_obj)
    routes = json_obj['routes'].each{ |route|
      city1 = route['ports'][0]
      city2 = route['ports'][1]
      distance = route['distance']
      distance = distance.to_i()
      tuple1 = OpenStruct.new
      tuple1.distance = distance
      tuple1.city = city2
      tuple2 = OpenStruct.new
      tuple2.distance = distance
      tuple2.city = city1
      node_hash[city1].linked_cities << tuple1
      node_hash[city2].linked_cities << tuple2
      route_name = city1.to_s() + "-" + city2.to_s()
      routes_hash[route_name] = distance
    }
  end
  
  # Method to add a new route to the CSAir network. Adds forward backward or both
  def add_route(city1, city2, direction)
    if(node_hash[city1] == nil || node_hash[city2] == nil)
      puts "INVALID CITY CODES"
      return
    else
      puts "Enter route distance"
      distance = gets
      distance = distance.to_i()
      if(!validate_input(distance))
        puts "Distance should be positive"
        return
      end
      if(direction == "FORWARD")
        puts "Adding #{city2} to #{city1} routes"
        add_city_to_linked(node_hash[city1].linked_cities, city2, distance)
      elsif(direction == "BACKWARD")
        puts "Adding #{city1} to #{city2} routes"
        add_city_to_linked(node_hash[city2].linked_cities, city1, distance)
      elsif(direction == "BOTH")
        puts "Adding #{city1} to #{city2} routes"
        puts "Adding #{city2} to #{city1} routes"
        if(add_city_to_linked(node_hash[city1].linked_cities, city2, distance) && add_city_to_linked(node_hash[city2].linked_cities, city1, distance))
          route_name = city1.to_s() + "-" + city2.to_s()
          routes_hash[route_name] = distance
        end
      else
        puts "INVALID DIRECTION INPUT"
      end
    end   
  end
  
  # Helper method to add a city to linked cities of the route. 
  def add_city_to_linked(linked_cities, code, distance)
    linked_cities.each{ |tuple|
      if(tuple.city == code)
        puts "This route already exists."
        return false
      end
    }
    tuple = OpenStruct.new
    tuple.distance = distance
    tuple.city = code
    linked_cities << tuple
    return true
  end
  
  # Method to add a new city tot he CSAir network.
  def add_city(code)
    if(node_hash[code] != nil)
      puts "CITY CODE already exists"
      return
    else
      puts "Enter the city name"
      name = gets
      puts "Enter the city's country"
      country = gets
      puts "Enter the city's timezone"
      timezone = gets
      puts "Enter the city's population"
      population = gets
      population = population.to_i()
      puts "Enter the city's continent"
      continent = gets
      puts "Enter the city's coordinates"
      coordinates = gets
      puts "Enter the city's region"
      region = gets
      if(validate_input(population))
        linked_cities = []
        new_node = Node.new(code,name,country,continent,timezone,coordinates,population,region,linked_cities)
        node_hash[code] = new_node
      end
    end
  end
  
  # Method to verify input by user is not invalid
  def validate_input(input)
    if(input < 1)
      return false
    end
    return true
  end
  
  # Method to remove a route from the CSAir network. Removes routes in forward, backward or both directions
  def remove_route(city1, city2, direction)
    if(node_hash[city1] == nil || node_hash[city2] == nil)
      puts "INVALID CITY CODES"
      return
    else
      if(direction == "FORWARD")
        puts "Removing #{city2} from #{city1} routes"
        remove_city_from_linked(node_hash[city1].linked_cities, city2)
      elsif(direction == "BACKWARD")
        puts "Removing #{city1} from #{city2} routes"
        remove_city_from_linked(node_hash[city2].linked_cities, city1)
      elsif(direction == "BOTH")
        puts "Removing #{city1} from #{city2} routes"
        puts "Removing #{city2} from #{city1} routes"
        remove_city_from_linked(node_hash[city1].linked_cities, city2)
        remove_city_from_linked(node_hash[city2].linked_cities, city1)
      else
        puts "INVALID DIRECTION INPUT"
      end
    end
  end
  
  # Method to remove a city from the CSAir network. Removes all routes to and from it.
  def remove_city(code)
    puts "Removing #{code}"
    city = node_hash[code]
    if(city == nil)
      puts "INVALID CITY CODE"
    else
      node_hash[code].linked_cities.each { |tuple|
        city_code = tuple.city
        puts "Removing #{code} from #{city_code}"
        remove_city_from_linked(node_hash[city_code].linked_cities, code)
      }
      continent_hash[city.continent].delete(city.name)
      node_hash.delete(code)
    end
  end
  
  # Helper method to remove linked cities of city to be removed.
  def remove_city_from_linked(linked_cities, code)
    linked_cities.each{ |tuple|
      if(tuple.city == code)
        linked_cities.delete(tuple)
        return
      end
    }
  end
  
  # Method to add a new json file with new cities to the CSAir network.
  def add_json(file)
    new_json = parse_json_file(file)
    store_all_cities(new_json)
    store_all_routes(new_json)
  end
  
  # Method for writing a new json file representing the CSAir network.
  def write_to_json
    p_hash = pretty_hash()
    File.open("map_data2.json","w") do |f|
      my_json = JSON.pretty_generate(p_hash)
      f.write(my_json)
    end
  end
  
  # Helper method to generate pretty version of graph
  def pretty_hash
    p_hash = {}
    p_hash["metros"] = []
    p_hash["routes"] = []
    node_hash.each_key{ |key|
      city = node_hash[key]
      p_hash["metros"] << city
    }
    return p_hash
  end
end