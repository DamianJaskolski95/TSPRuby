class Graph

  attr_reader :vertices
  attr_accessor :main_array
  attr_accessor :main_hash
  attr_reader :best_known_result

  def initialize(n, best = 0)
    @vertices = n
    @best_known_result = best
    @main_array = Array.new(n, -1)
    @main_array.map! { Array.new(n, -1)}
    @main_hash = Hash.new(-1)
  end

  def print_array
    @main_array.each() do |ver|
      print "#{ver}\n"
    end
  end

  def generate_graph
    (0...@vertices).each() do |i|
      (0...@vertices).each() do |j|
        if i != j
          @main_array[i][j] = rand(200)
          @main_hash[[i, j]] = @main_array[i][j]
        end
      end
    end
  end

  def read_file(filename)

    file_contents = File.read(filename)
    numbers = file_contents.scan(/\d+/)
    numbers.collect! &:to_i

    initialize(numbers[0], numbers[1])
    number_count = 2
    (0...@vertices).each() do |i|
      (0...@vertices).each() do |j|
        if i != j
          @main_array[i][j] = numbers[number_count]
          @main_hash[[i, j]] = @main_array[i][j]
        end
        number_count += 1
      end
    end
  end

  def reference_graph
    @main_array = [[-1, 20, 30, 31, 28, 40], [30, -1, 10, 14, 20, 44], [40, 20, -1, 10, 22, 50], [41, 24, 20, -1, 14, 42], [38, 30, 32, 24, -1, 28], [50, 54, 60, 52, 38, -1]]
    (0...@vertices).each() do |i|
      (0...@vertices).each() do |j|
        @main_hash[[i, j]] = @main_array[i][j]
      end
    end
  end
end
