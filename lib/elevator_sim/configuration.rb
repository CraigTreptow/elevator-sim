# frozen_string_literal: true

require 'tomlrb'

module ElevatorSim
  class Configuration
    attr_reader :data

    def initialize(config_path)
      @config_path = config_path
      @data = load_config
    end

    def self.load(config_path)
      new(config_path)
    end

    # Building configuration
    def building_floors
      @data.dig('building', 'floors')
    end

    def basement_floors
      @data.dig('building', 'basement_floors')
    end

    # Elevator configuration
    def elevator_count
      @data.dig('elevators', 'main', 'count')
    end

    def elevator_capacity
      @data.dig('elevators', 'main', 'capacity')
    end

    def elevator_speed
      @data.dig('elevators', 'main', 'speed_floors_per_second')
    end

    def door_open_time
      @data.dig('elevators', 'main', 'door_open_time')
    end

    def door_close_time
      @data.dig('elevators', 'main', 'door_close_time')
    end

    def service_floors
      @data.dig('elevators', 'main', 'service_floors')
    end

    # Simulation configuration
    def duration_minutes
      @data.dig('simulation', 'duration_minutes')
    end

    def user_spawn_rate
      @data.dig('simulation', 'user_spawn_rate')
    end

    def random_seed
      @data.dig('simulation', 'random_seed')
    end

    # User configuration
    def user_movement_speed
      @data.dig('users', 'movement_speed')
    end

    def button_press_delay
      @data.dig('users', 'button_press_delay')
    end

    def floor_distribution
      @data.dig('users', 'floor_distribution')
    end

    private

    def load_config
      unless File.exist?(@config_path)
        raise "Configuration file not found: #{@config_path}"
      end

      Tomlrb.load_file(@config_path)
    rescue Tomlrb::ParseError => e
      raise "Invalid TOML configuration: #{e.message}"
    end
  end
end