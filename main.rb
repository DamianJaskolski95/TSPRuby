# Program for resolving TSP problem.

require "benchmark"
require "./graph"
require "./tsp"

if __FILE__ == $0
  puts "Program to resolve TSP problem."
  puts "1. Generate matrix"
  puts "2. Read matrix from file"

  decision = gets.chomp
  case decision
  when "1"
    puts "How many vertices?"
    vertices = gets.chomp.to_i
    graph_main = Graph.new(vertices)
    graph_main.generate_graph
    #graph_main.reference_graph
    #graph_main.print_array
    #puts graph_main.main_hash
  when "2"
    puts "File name:"
    filename = gets.chomp
    graph_main = Graph.new(1)
    graph_main.read_file(filename)

    #graph_main.print_array
  else
    puts "Wrong number."
  end

  while decision != "0"
    puts "Which algorithm you want to use?";
    puts "0. Exit"
    puts "1. Print graph - matrix"
    puts "2. Print graph - hash"
    puts "3. Brute Force - matrix"
    puts "4. Brute Force - hash"
    puts "5. Simulated Annealing - matrix"
    puts "6. Simulated Annealing - hash"
    puts "7. Ant Colony System - matrix"
    puts "8."
    puts "9. Benchmark for all (may take some time) - max for 20"
    puts "10. Benchmark for SA and ACS"

    decision = gets.chomp

    case decision

    when "0"
      puts "Bye!"

    when "1"
      graph_main.print_array

    when "2"
      puts graph_main.main_hash

    when "3"
      brute_main_matrix = BruteForce.new(graph_main)
      puts Benchmark.measure { brute_main_matrix.start_brute_force_matrix }
      puts "Result:"
      brute_main_matrix.print_best_path
      puts "Best known result: #{graph_main.best_known_result}"

    when "4"
      brute_main_hash = BruteForce.new(graph_main)
      puts Benchmark.measure { brute_main_hash.start_brute_force_hash }
      brute_main_hash.print_best_path
      puts "Best known result: #{graph_main.best_known_result}"

    when "5"
      sa_main_matrix = SimulatedAnnealing.new(graph_main)
      puts Benchmark.measure { sa_main_matrix.start_sa_matrix }
      sa_main_matrix.print_best_path
      puts "Best known result: #{graph_main.best_known_result}"

    when "6"
      sa_main_hash = SimulatedAnnealing.new(graph_main)
      puts Benchmark.measure { sa_main_hash.start_sa_hash }
      sa_main_hash.print_best_path
      puts "Best known result: #{graph_main.best_known_result}"

    when "7"
      acs_main_matrix = AntColony.new(graph_main)
      puts Benchmark.measure { acs_main_matrix.start_ant_colony_matrix }
      acs_main_matrix.print_best_path
      puts "Best known result: #{graph_main.best_known_result}"
	
	when "8"
      puts "Not yet implemented"

    when "9"
      brute_main_matrix = BruteForce.new(graph_main)
      brute_main_hash = BruteForce.new(graph_main)
      sa_main_matrix = SimulatedAnnealing.new(graph_main)
      sa_main_hash = SimulatedAnnealing.new(graph_main)
      Benchmark.bm do |x|
        x.report("BFm:")   { brute_main_matrix.start_brute_force_matrix }
        puts "BF matrix path = #{brute_main_matrix.result}"
        x.report("BFh:") { brute_main_hash.start_brute_force_hash }
        puts "BF hash path = #{brute_main_hash.result}"
        x.report("SAm:")  { sa_main_matrix.start_sa_matrix }
        puts "SA matrix path = #{sa_main_matrix.result}"
        x.report("SAh")  { sa_main_hash.start_sa_hash }
        puts "SA hash path = #{sa_main_hash.result}"
      end
    when "10"
      sa_main_matrix = SimulatedAnnealing.new(graph_main)
      sa_main_hash = SimulatedAnnealing.new(graph_main)
      acs_main_matrix = AntColony.new(graph_main)
      
      Benchmark.bm do |x|
        x.report("SAm:")  { sa_main_matrix.start_sa_matrix }
        puts "SA matrix path = #{sa_main_matrix.result}"
        x.report("SAh:")  { sa_main_hash.start_sa_hash }
        puts "SA hash path = #{sa_main_hash.result}"
        x.report("ACm:")  { acs_main_matrix.start_ant_colony_matrix }
        puts "ACS matrix path = #{acs_main_matrix.result}"
      end
    else
      puts "Wrong number."
    end
  end

end
