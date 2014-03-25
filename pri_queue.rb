require 'ostruct'

# A simple priority queue implementation
class Priqueue
  
  # initialize an empty queue
  def initialize
    @queue = []
  end
  
  # Push a new city, distance tuple on the queue.
  def push(city, distance)
    tuple = OpenStruct.new
    tuple.city = city
    tuple.distance = distance
    @queue << tuple
  end
  
  # Pop the tuple with the minimum distance from the queue
  def pop()
    min_dist = 1.0/0.0
    min_tuple = nil
    @queue.each{ |tuple|
      if(tuple.distance < min_dist)
        min_dist = tuple.distance
        min_tuple = tuple
      end
    }
    return @queue.delete(min_tuple)
  end
end
  