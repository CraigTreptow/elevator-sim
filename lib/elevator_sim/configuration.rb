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