class Journey
  @@plane_speed = 750.to_f()/60
  
  # Create a journey between a series of cities
  def initialize(input)
    @origin = input[0]
    puts "Origin #{@origin}"
    @destination = input[input.size()-1]
    puts "Destination #{@destination}"
    @stopovers = input
    @total_distance = 0
    @cost = 0
    @layover_time = 0
    @total_time = 0
    @rate = 0.35
    @layover_rate = 120
  end
  
  # MEthod to validate journey
  def validate_route(graph_instance)
    @stopovers.each_index{ |i|
      if(i+1 < @stopovers.size())
        if(!is_valid_route(@stopovers[i], @stopovers[i+1], graph_instance))
          puts "#{@stopovers[i]}-#{@stopovers[i+1]} is not a valid route"
          return false
        end
      end
    }
  end
  
  # Helper method to check validity of route and calculate statistics
  def is_valid_route(stop1, stop2, graph_instance)
    city1 = graph_instance.node_hash[stop1]
    @layover_time = @layover_time + (@layover_rate - city1.linked_cities.size()*10)
    city1.linked_cities.each { |tuple|
      if(tuple.city == stop2)
        @total_distance = @total_distance + tuple.distance
        if(stop1 == @origin)
          @cost = @cost + @rate*tuple.distance
        else
          if(@rate != 0)
            @rate = @rate-0.05
          end
          @cost = @cost + @rate*tuple.distance
        end
        return true
      end
    }
    return false
  end
  
  def get_distance
    puts "Total distance in journey is #{@total_distance}"
  end
  
  def get_cost
    puts "Total cost of journey is #{@cost}"
  end
  
  # Helper method to calculate time of flight
  def get_time
    if(@total_distance < 400)
      s_dist = (@total_distance/2)
      acceleration = (@@plane_speed**2)/(2*s_dist)
      time = @plane_speed/acceleration
      @total_time = 2*time + @layover_time
    else
      s_dist = 200
      acceleration = (@@plane_speed**2)/(2*s_dist)
      time = @@plane_speed/acceleration
      air_dist = @total_distance - 400
      @total_time = 2*time + (air_dist/@@plane_speed) + @layover_time
    end
    puts "Total time for your journey is #{@total_time} minutes"
  end
end