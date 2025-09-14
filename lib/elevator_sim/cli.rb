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
      puts "  init            Create configuration wizard"
      puts "  version         Show version"
      puts
      puts "Use 'elevator-sim [command] --help' for more information"
    end

    private

    def handle_command(args)
      command = args.shift

      case command
      when "generate-queue"
        generate_queue_command(args)
      when "show-queue"
        show_queue_command(args)
      when "version"
        puts "v#{VERSION}"
      else
        puts "Unknown command: #{command}"
        puts "Run 'elevator-sim' for available commands"
      end
    end

    def generate_queue_command(args)
      config_file = extract_option(args, "--config") || "config/default.toml"
      output_file = extract_option(args, "--output") || "queues/default.json"

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
      queue_file = extract_option(args, "--queue") || "queues/default.json"
      limit = extract_option(args, "--limit")&.to_i || 10

      puts "📋 Queue: #{queue_file}"

      begin
        queue = Queue.load(queue_file)

        puts "\nMetadata:"
        queue.metadata.each { |key, value| puts "  #{key}: #{value}" }

        puts "\nPeople (showing first #{limit}):"
        queue.people.first(limit).each do |person|
          time = sprintf("%.1f", person["spawn_time"])
          puts "  Person #{person["id"]}: t=#{time}s, Floor #{person["origin_floor"]}→#{person["destination_floor"]}"
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

      args.delete_at(index + 1)
      args.delete_at(index)
    end
  end
end
