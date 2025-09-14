# frozen_string_literal: true

module ElevatorSim
  class CLI
    def self.start(args)
      new.start(args)
    end

    def start(args)
      puts "🏢 Elevator Simulation CLI v#{VERSION}"
      puts "Usage: elevator-sim [command] [options]"
      puts
      puts "Commands:"
      puts "  run       Run a single simulation"
      puts "  simulate  Interactive simulation with real-time visualization"
      puts "  compare   Compare multiple algorithms"
      puts "  init      Create configuration wizard"
      puts "  version   Show version"
      puts
      puts "Use 'elevator-sim [command] --help' for more information"
    end
  end
end