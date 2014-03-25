# Node class for a graph of a specified CSAir Node (City)
class Node
  
  # Initialize method for creating a new node(city)
  # @param - code, name, country, continent, timezone, coordinates, population, region, linked_cities
  def initialize(code, name, country, continent, timezone, coordinates, population, region, linked_cities)
    @code = code
    @name = name
    @country = country
    @continent = continent
    @timezone = timezone
    @coordinates = coordinates
    @population = population
    @region = region
    @linked_cities = linked_cities
  end
  attr_reader :linked_cities, :code, :name, :country, :continent, :timezone, :coordinates, :population, :region
end