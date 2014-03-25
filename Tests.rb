require 'test/unit'
require 'stringio'
require 'Node.rb'
require 'Graph.rb'
require 'RoutesInterface.rb'
require 'Dijkstra.rb'

module Kernel
 
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
 
end

class Tests < Test::Unit::TestCase
  
  def test_node_info
    new_city = Node.new('MEX','Mexico City','MX','North America','-6','W99N19','23400000','1',[])
    assert_equal('MEX', new_city.code)
    assert_equal('Mexico City', new_city.name)
    assert_equal('MX', new_city.country)
    assert_equal('North America', new_city.continent)
    assert_equal('-6', new_city.timezone)
    assert_equal('W99N19', new_city.coordinates)
    assert_equal('23400000', new_city.population)
    assert_equal('1', new_city.region)
  end
  
  def test_average_distance
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    out = capture_stdout do
      print_average_distance graph_instance
    end
    assert_equal("Average flight distance is 2300\n", out.string)
  end
  
  def test_biggest_population
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    out = capture_stdout do
      print_biggest_population graph_instance
    end
    assert_equal("Biggest population is 34000000 in Tokyo\n", out.string)
  end
  
  def test_smallest_population
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    out = capture_stdout do
      print_smallest_population graph_instance
    end
    assert_equal("Smallest population is 589900 in Essen\n", out.string)
  end
  
  def test_average_population
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    out = capture_stdout do
      print_average_population graph_instance
    end
    assert_equal("Average population is 11796143.\n", out.string)
  end
  
  def test_remove_city
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    graph_instance.remove_city("MEX")
    out = capture_stdout do
      print_city_info("MEX", graph_instance)
    end
    assert_equal("Not a valid city code\n", out.string)
  end
  
  def test_remove_route_forward
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    graph_instance.remove_route("MEX","BOG","FORWARD")
    input = [" ","MEX", "BOG"]
    out = capture_stdout do
      create_journey(input, graph_instance)
    end
    assert_equal("Origin MEX\nDestination BOG\nMEX-BOG is not a valid route\n", out.string)
  end
  
  def test_remove_route_backward
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    graph_instance.remove_route("MEX","BOG","BACKWARD")
    input = [" ","BOG", "MEX"]
    out = capture_stdout do
      create_journey(input, graph_instance)
    end
    assert_equal("Origin BOG\nDestination MEX\nBOG-MEX is not a valid route\n", out.string)
  end
  
  def test_journey
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    input = [" ","BOG", "MEX"]
    out = capture_stdout do
      create_journey(input, graph_instance)
    end
    assert_equal("Origin BOG\nDestination MEX\nTotal distance in journey is 3158\nTotal cost of journey is 1105.3\nTotal time for your journey is 354.64 minutes\n", out.string)
  end
  
  def test_dijsktra
    graph_instance = Graph.new('map_data.json')
    json_obj = graph_instance.parse_json_file("map_data.json")
    graph_instance.store_all_cities(json_obj)
    graph_instance.store_all_routes(json_obj)
    out = capture_stdout do
      find_journey("MEX", "SCL", graph_instance)
    end
    #assert_equal("Shortest distance is 6684 with stopovers at\nLIM\nMEX\n", out)
  end
end