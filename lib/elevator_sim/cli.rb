# frozen_string_literal: true

module ElevatorSim
  class CLI
    def self.start(args)
      new.start(args)
    end

    def start(args)
      return handle_command(args) unless args.empty?

      puts "🏢 Elevator Simulation CLI v#{VERSION}"
      puts "Usage: elevator-sim [command] [options]"
      puts
      puts "Commands:"
      puts "  run             Run a single simulation"
      puts "  simulate        Interactive simulation with real-time visualization"
      puts "  compare         Compare multiple algorithms"
      puts "  generate-queue  Generate a reproducible queue of people"
      puts "  show-queue      Display queue contents"
      puts "  list-queues     List all available queues"
      puts "  show-building   Display building configuration"
      puts "  init            Create configuration wizard"
      puts "  version         Show version"
      puts
      puts "Examples:"
      puts "  elevator-sim run --config config/default.toml --algorithm algorithms/fifo.rb"
      puts "  elevator-sim simulate --algorithm algorithms/fifo.rb --interactive"
      puts "  elevator-sim simulate --algorithm algorithms/fifo.rb --interactive --visual"
      puts "  elevator-sim simulate --algorithm algorithms/fifo.rb --visual"
      puts "  elevator-sim generate-queue --name rush_hour"
      puts "  elevator-sim show-queue --name rush_hour"
      puts "  elevator-sim list-queues"
      puts "  elevator-sim show-building"
      puts
      puts "Use 'elevator-sim [command] --help' for more information"
    end

    private

    def handle_command(args)
      command = args.shift

      case command
      when "run"
        run_simulation_command(args)
      when "simulate"
        simulate_command(args)
      when "generate-queue"
        generate_queue_command(args)
      when "show-queue"
        show_queue_command(args)
      when "list-queues"
        list_queues_command(args)
      when "show-building"
        show_building_command(args)
      when "version"
        puts "v#{VERSION}"
      else
        puts "Unknown command: #{command}"
        puts "Run 'elevator-sim' for available commands"
      end
    end

    def generate_queue_command(args)
      config_file = extract_option(args, "--config") || "config/default.toml"
      queue_name = extract_option(args, "--name") || "default"
      output_file = extract_option(args, "--output") || "queues/#{queue_name}.json"

      puts "🎯 Generating queue..."
      puts "  Config: #{config_file}"
      puts "  Output: #{output_file}"

      begin
        config = Configuration.load(config_file)
        queue = Queue.generate(config)

        # Ensure queues directory exists
        require "fileutils"
        FileUtils.mkdir_p(File.dirname(output_file))

        queue.save_to_file(output_file)

        puts "✅ Generated #{queue.people.length} people"
        puts "  Duration: #{config.duration_minutes} minutes"
        puts "  Spawn rate: #{config.user_spawn_rate} people/second"
        puts "  Seed: #{config.random_seed}"
      rescue => e
        puts "❌ Error: #{e.message}"
      end
    end

    def show_queue_command(args)
      queue_name = extract_option(args, "--name") || extract_option(args, "--queue") || "default"
      queue_file = queue_name.end_with?(".json") ? "queues/#{queue_name}" : "queues/#{queue_name}.json"
      limit = extract_option(args, "--limit")&.to_i || 10

      puts "📋 Queue: #{queue_file}"

      begin
        queue = Queue.load(queue_file)

        puts "\nMetadata:"
        queue.metadata.each { |key, value| puts "  #{key}: #{value}" }

        puts "\nPeople (showing first #{limit}):"
        queue.people.first(limit).each do |person|
          time = sprintf("%.1f", person["spawn_time"])
          start_floor = person["start_floor"] || person["origin_floor"] # Handle both old and new format
          puts "  Person #{person["id"]}: t=#{time}s, Floor #{start_floor}→#{person["destination_floor"]}"
        end

        if queue.people.length > limit
          puts "  ... and #{queue.people.length - limit} more"
        end

        puts "\nTotal: #{queue.people.length} people"
      rescue => e
        puts "❌ Error: #{e.message}"
      end
    end

    def extract_option(args, option_name)
      index = args.find_index(option_name)
      return nil unless index && index < args.length - 1

      value = args.delete_at(index + 1)
      args.delete_at(index)
      value
    end

    def extract_flag(args, flag_name)
      index = args.find_index(flag_name)
      return false unless index

      args.delete_at(index)
      true
    end

    def list_queues_command(args)
      puts "📋 Available queues:"

      begin
        queue_dir = "queues"

        unless Dir.exist?(queue_dir)
          puts "  No queues directory found. Generate a queue first with:"
          puts "  ./bin/elevator-sim generate-queue --name myqueue"
          return
        end

        queue_files = Dir.glob("#{queue_dir}/*.json").sort

        if queue_files.empty?
          puts "  No queues found. Generate a queue first with:"
          puts "  ./bin/elevator-sim generate-queue --name myqueue"
          return
        end

        queue_files.each do |file_path|
          queue = Queue.load(file_path)
          name = File.basename(file_path, ".json")
          metadata = queue.metadata

          puts "  #{name} (#{queue.people.length} people, #{metadata["duration_minutes"]}min, seed: #{metadata["seed"]})"
        rescue => e
          name = File.basename(file_path, ".json")
          puts "  #{name} (error: #{e.message})"
        end

        puts
        puts "Use with: ./bin/elevator-sim show-queue --name <queue_name>"
      rescue => e
        puts "❌ Error: #{e.message}"
      end
    end

    def show_building_command(args)
      config_file = extract_option(args, "--config") || "config/default.toml"

      puts "🏢 Building Configuration"
      puts "  Config: #{config_file}"
      puts

      begin
        config = Configuration.load(config_file)
        building = Building.new(config)

        puts building
      rescue => e
        puts "❌ Error: #{e.message}"
      end
    end

    def run_simulation_command(args)
      config_file = extract_option(args, "--config") || "config/default.toml"
      algorithm_file = extract_option(args, "--algorithm") || "algorithms/fifo.rb"
      queue_name = extract_option(args, "--queue")

      puts "🏃 Running simulation..."
      puts "  Config: #{config_file}"
      puts "  Algorithm: #{algorithm_file}"
      puts "  Queue: #{queue_name || "Generated on-the-fly"}"
      puts

      begin
        config = Configuration.load(config_file)
        building = Building.new(config)
        algorithm = AlgorithmLoader.load_from_file(algorithm_file, building, config)

        # Load or generate queue
        queue = if queue_name
          queue_file = queue_name.end_with?(".json") ? "queues/#{queue_name}" : "queues/#{queue_name}.json"
          Queue.load(queue_file)
        else
          Queue.generate(config)
        end

        simulation = Simulation.new(config, algorithm, queue)

        puts "▶️  Starting simulation (#{config.duration_minutes} minutes)..."
        start_time = Time.now

        simulation.run

        end_time = Time.now
        puts
        puts "✅ Simulation completed in #{(end_time - start_time).round(2)}s"
      rescue => e
        puts "❌ Error: #{e.message}"
        puts e.backtrace.first(5).join("\n") if ENV["DEBUG"]
      end
    end

    def simulate_command(args)
      config_file = extract_option(args, "--config") || "config/default.toml"
      algorithm_file = extract_option(args, "--algorithm") || "algorithms/fifo.rb"
      queue_name = extract_option(args, "--queue")
      interactive = extract_flag(args, "--interactive")
      visual = extract_flag(args, "--visual")

      puts "🎮 Interactive simulation..."
      puts "  Config: #{config_file}"
      puts "  Algorithm: #{algorithm_file}"
      puts "  Queue: #{queue_name || "Generated on-the-fly"}"
      puts "  Interactive: #{interactive ? "Yes" : "No"}"
      puts "  Visual: #{visual ? "Yes" : "No"}"
      puts

      begin
        config = Configuration.load(config_file)
        building = Building.new(config)
        algorithm = AlgorithmLoader.load_from_file(algorithm_file, building, config)

        # Load or generate queue
        queue = if queue_name
          queue_file = queue_name.end_with?(".json") ? "queues/#{queue_name}" : "queues/#{queue_name}.json"
          Queue.load(queue_file)
        else
          Queue.generate(config)
        end

        simulation = Simulation.new(config, algorithm, queue)

        if interactive
          if visual
            visualization = Visualization.new(building)
            run_visual_interactive_simulation(simulation, config, visualization)
          else
            run_text_interactive_simulation(simulation, config)
          end

          puts "\n📊 Final Statistics:"
          stats = simulation.statistics
          puts "  Total Users: #{stats[:total_users]}"
          puts "  Completed: #{stats[:completed_users]}"
          puts "  Avg Wait Time: #{stats[:average_wait_time].round(2)}s"
          puts "  Avg Ride Time: #{stats[:average_ride_time].round(2)}s"
          puts "  Utilization: #{(stats[:elevator_utilization] * 100).round(1)}%"
        elsif visual
          visualization = Visualization.new(building)
          run_visual_automatic_simulation(simulation, config, visualization)
        else
          simulation.run
        end
      rescue => e
        puts "❌ Error: #{e.message}"
        puts e.backtrace.first(5).join("\n") if ENV["DEBUG"]
      end
    end

    def run_text_interactive_simulation(simulation, config)
      puts "🔄 Interactive mode - Press Enter to step through simulation"
      puts "    Type 'quit' to exit early"

      step_count = 0
      loop do
        simulation.step_simulation
        step_count += 1

        state = simulation.current_state
        puts "\n--- Step #{step_count} (#{state[:time].round(1)}s) ---"
        puts "Active users: #{state[:users].length}"
        puts "Call requests: #{state[:call_requests].length}"

        state[:building].elevators.each do |elevator|
          puts "  #{elevator}"
        end

        break if state[:time] >= config.duration_minutes * 60

        print "\nPress Enter for next step (or 'quit'): "
        input = $stdin.gets
        break if input.nil? || input.chomp.downcase == "quit"
      end
    end

    def run_visual_interactive_simulation(simulation, config, visualization)
      puts "🎨 Visual interactive mode - Press Enter to step through simulation"
      puts "    Type 'quit' to exit early"
      puts "    Initializing visualization..."
      sleep(1)

      visualization.clear_screen

      step_count = 0
      loop do
        simulation.step_simulation
        step_count += 1

        state = simulation.current_state
        visualization.render_frame(state)

        break if state[:time] >= config.duration_minutes * 60

        print "\nPress Enter for next step (or 'quit'): "
        input = $stdin.gets
        break if input.nil? || input.chomp.downcase == "quit"
      end
    end

    def run_visual_automatic_simulation(simulation, config, visualization)
      puts "🎬 Visual automatic mode - Watch the simulation run in real-time"
      puts "    Press Ctrl+C to exit early"
      puts "    Initializing visualization..."
      sleep(1)

      visualization.clear_screen

      update_frequency = 0.2  # Update every 200ms for smooth animation
      last_update = Time.now

      begin
        loop do
          simulation.step_simulation

          # Update visualization at regular intervals
          current_time = Time.now
          if current_time - last_update >= update_frequency
            state = simulation.current_state
            visualization.render_frame(state)
            last_update = current_time
          end

          break if simulation.current_state[:time] >= config.duration_minutes * 60

          # Small sleep to prevent excessive CPU usage
          sleep(0.05)
        end

        # Final update
        state = simulation.current_state
        visualization.render_frame(state)

        # Show final statistics
        puts "\n\n📊 Final Simulation Results:"
        simulation.generate_statistics
      rescue Interrupt
        puts "\n\n⏹️  Simulation interrupted by user"
        puts "\n📊 Partial Results:"
        simulation.generate_statistics
      end
    end
  end
end
