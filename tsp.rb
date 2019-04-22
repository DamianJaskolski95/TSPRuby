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

  attr_reader :pheromon_array

  def start_ant_colony_matrix
    #parameters
    max_iterations = 1
    ant_amount = 10

    alpha = 1.0
    beta = 2.0
    rho = 0.1
    xi = 0.1
    q0 = 0.75

    @ants = Array.new(ant_amount) { Ant.new(@graph.vertices) }

    @init_pheromone = initialize_pheromon_table()

    @pheromon_array = Array.new(@graph.vertices, -1)
    @pheromon_array.map! { Array.new(@graph.vertices, @init_pheromone)}

    (0...max_iterations).each() do
      i = 0
      (0...@ants.count).each() do |ant|
        i = 0 if i == @graph.vertices
        @ants[ant] = init_ant_start(@ants[ant], i)
        i += 1
      end

      (0...@graph.vertices).each() do |find_city|
        (0...@ants.count).each() do |ant|
          @ants[ant] = find_path(@ants[ant], alpha, beta, q0, xi, find_city)
        end
      end
    end
  end

  def count_eta (val)
    if val != 0
      eta = 1/val
    else
      eta = 1/0.1
    end

    return eta
  end


  def find_path(ant, alpha, beta, q0, xi, find_city)
    #(0...@graph.vertices).each() do |find_city|
      #next if ant.cur_ant_path[find_city] != -1
      sum = 0.0
      eta = 0.0
      pher = 0.0
      best_val = 0.0
      best_i = 0

      to_go_table = Array.new(@graph.vertices, 0)
      to_go_table2 = Array.new(@graph.vertices, 0)

      (0...@graph.vertices).each() do |iter|
        next if ant.visited[iter] == 0
        eta = count_eta(@graph.main_array[ant.cur_ant_path[find_city-1]][iter])
        pher = @pheromon_array[ant.cur_ant_path[find_city-1]][iter]
        sum += pher**alpha + eta**beta
      end

      (0...@graph.vertices).each() do |iter|
        next if ant.visited[iter] == 0
        eta = count_eta(@graph.main_array[ant.cur_ant_path[find_city-1]][iter])
        pher = @pheromon_array[ant.cur_ant_path[find_city-1]][iter]
        random_proportial = pher**alpha + eta**beta
        random_proportial2 = pher + eta**beta
        to_go_table[iter] = random_proportial
        to_go_table[iter] = random_proportial2
      end

      if rand() <= q0
        (0...to_go_table2.count).each() do |find_best|
          if to_go_table2[find_best] > best_val
            best_val = to_go_table2[find_best]
            best_i = find_best
          end
        end
        ant.cur_ant_path[find_city] = best_i
        ant.visited[best_i] = 0

        update_pheromone_ACS(xi, ant.cur_ant_path[find_city-1], ant.cur_ant_path[find_city])
      end
    #end

    return ant
  end

  def init_ant_start(ant, b = -1) #-1 is random, provide b arg to start at this point
    if b == -1
      r = rand(@graph.vertices)

      ant.cur_ant_path[0] = r
      ant.cur_ant_path[r] = -1 if r != 0
      ant.visited[r] = 0

    else
      ant.cur_ant_path[0] = b
      ant.cur_ant_path[b] = -1 if b != 0
      ant.visited[b] = 0
    end

    return ant

  end

  def initialize_pheromon_table
    temp_path = init_path()
    avg = 0.0
    temp_path.each() do
      temp_path.shuffle!
      avg += count_path_matrix(temp_path)
    end
    avg /= @graph.vertices
    init_pheromone = (@ants.count/avg)
    #init_pheromone = 1/(avg*@graph.vertices)

    return init_pheromone

  end

  def update_pheromone_ACS(xi, a, b)
    @pheromon_array[a][b] *= (1 - xi)
    @pheromon_array[a][b] += (xi * @init_pheromone)
  end

end

class Ant
  attr_accessor :visited
  attr_accessor :min_ant_path
  attr_accessor :cur_ant_path

  def initialize(vert)
    @min_ant_path = init_path(vert)
    @cur_ant_path = init_path(vert, -1)
    @visited = init_path(vert, -1)
  end

  private
  def init_path(vert, val = 0)
    path = Array.new(vert, val)

    (0...vert).each() { |i| path[i] = i } if val == 0

    return path
  end

  def copy_path(path)
    copy_array = Array.new(vert, 0)
    (0...@graph.vertices).each() do |i|
      copy_array[i] = path[i]
    end
    return copy_array
  end

end
