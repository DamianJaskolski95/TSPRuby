class TspBase

  attr_accessor :result
  attr_accessor :graph
  attr_accessor :path

  def initialize(graph)
    @graph = graph
    @path = init_path()
    @result = count_path_matrix(@path)
  end

  def init_path()
    path = Array.new(@graph.vertices, 0)
    (0...@graph.vertices).each() do |i|
      path[i] = i
    end
    return path
  end

  def print_best_path
    @path.each() do |p|
      print "#{p}->"
    end
    puts "Value of that best path is #{@result}"
  end

  private
  def count_path_matrix(path)
    temp_result = 0
    (0...@graph.vertices-1).each() do |i|
      temp_result += @graph.main_array[path[i]][path[i+1]]
    end
    temp_result += @graph.main_array[path[@graph.vertices-1]][path[0]]
    return temp_result
  end

  def count_path_hash(path)
    temp_result = 0
    (0...@graph.vertices-1).each() do |i|
      temp_result += @graph.main_hash[[path[i], path[i+1]]]
    end
    temp_result += @graph.main_hash[[path[@graph.vertices-1], path[0]]]
    return temp_result
  end

  def print_path(path)
    path.each() do |p|
      print "#{p}->"
    end
    puts "\nValue of that path is #{count_path_matrix(path)}"
  end

  def swap2rand(path)
    a = rand(@graph.vertices)
    b = rand(@graph.vertices)
    while a == b do
      b = rand(@graph.vertices)
    end
    path[a], path[b] = path[b], path[a]

    return path
  end

  def copy_path(path)
    copy_array = Array.new(@graph.vertices, 0)
    (0...@graph.vertices).each() do |i|
      copy_array[i] = path[i]
    end
    return copy_array
  end

end

class BruteForce < TspBase

  def start_brute_force_matrix
    min_result = count_path_matrix(@path)

    permutations = @path.permutation.to_a
    permutations.each() do |per|
      #print "#{per}\n"
      if count_path_matrix(per) < min_result
        min_result = count_path_matrix(per)
        @path = copy_path(per)
      end
    end
    @result = min_result
  end

  def start_brute_force_hash

    min_result = count_path_hash(@path)

    permutations = @path.permutation.to_a
    permutations.each() do |per|
      #print "#{per}\n"
      if count_path_hash(per) < min_result
        min_result = count_path_hash(per)
        @path = copy_path(per)
      end
    end
    @result = min_result

  end

end

class SimulatedAnnealing < TspBase

  def start_sa_matrix
    #parameters
    coefficients = [0.999]
    min_temperature = 0.0001
    epoch = 10

    resolve_problem_matrix(coefficients, min_temperature, epoch)

  end

  def start_sa_hash
    #parameters
    coefficients = [0.999]
    min_temperature = 0.0001
    epoch = 10

    resolve_problem_hash(coefficients, min_temperature, epoch)

  end

  private
  def init_temperature_matrix
    temp_path = init_path()
    avg = 0.0

    (0...@graph.vertices).each() do
      temp_path.shuffle!
      avg += count_path_matrix(temp_path)
    end

    avg /= @graph.vertices

    return avg
  end

  def init_temperature_hash
    temp_path = init_path()
    avg = 0.0

    (0...@graph.vertices).each() do
      temp_path.shuffle!
      avg += count_path_hash(temp_path)
    end

    avg /= @graph.vertices

    return avg
  end

  def resolve_problem_matrix(coefficients, min_temperature, epoch)
    coefficients.each() do |coef|
      temperature = init_temperature_matrix()
      temp_path = init_path()
      new_path = init_path()

      temp_path.shuffle!
      while true do
        (0...epoch).each() do |epo|
            new_path = copy_path(temp_path)
            new_path = swap2rand(new_path)

            gain = count_path_matrix(new_path) - count_path_matrix(temp_path)
            p_val = -(gain/temperature)
            pt = Math.exp(p_val)

            if gain < 0 || pt > rand()
              temp_path = copy_path(new_path)
              if count_path_matrix(temp_path) < count_path_matrix(@path)
                @path = copy_path(temp_path)
                @result = count_path_matrix(@path)
              end
            end
        end

        temperature *= coef
        break if temperature < min_temperature
      end
    end
  end

  def resolve_problem_hash(coefficients, min_temperature, epoch)
    coefficients.each() do |coef|
      temperature = init_temperature_hash()
      temp_path = init_path()
      new_path = init_path()

      temp_path.shuffle!
      while true do
        (0...epoch).each() do |epo|
            new_path = copy_path(temp_path)
            new_path = swap2rand(new_path)

            gain = count_path_hash(new_path) - count_path_hash(temp_path)
            p_val = -(gain/temperature)
            pt = Math.exp(p_val)

            if gain < 0 || pt > rand()
              temp_path = copy_path(new_path)
              if count_path_hash(temp_path) < count_path_hash(@path)
                @path = copy_path(temp_path)
                @result = count_path_hash(@path)
              end
            end
        end

        temperature *= coef
        break if temperature < min_temperature
      end
    end
  end
end

class AntColony < TspBase

  def start_ant_colony

  end

end
