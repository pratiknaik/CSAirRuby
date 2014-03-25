require 'Graph.rb'
require 'RoutesInterface.rb'

# Script to run the entire CSAir Routes program
graph_instance = Graph.new("map_data.json")
json_obj = graph_instance.parse_json_file("map_data.json")
graph_instance.store_all_cities(json_obj)
graph_instance.store_all_routes(json_obj)
start_text_ui(graph_instance)