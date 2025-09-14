# frozen_string_literal: true

require "json"

module ElevatorSim
  class Queue
    attr_reader :people, :metadata

    def initialize(config)
      @config = config
      @people = []
      @metadata = {}
    end

    def self.generate(config)
      queue = new(config)
      queue.generate_people
      queue
    end

    def self.load(file_path)
      data = JSON.parse(File.read(file_path))
      queue = allocate
      queue.instance_variable_set(:@people, data["people"])
      queue.instance_variable_set(:@metadata, data["metadata"])
      queue
    end

    def generate_people
      Random.srand(@config.random_seed)

      @metadata = {
        "seed" => @config.random_seed,
        "duration_minutes" => @config.duration_minutes,
        "spawn_rate" => @config.user_spawn_rate,
        "generated_at" => Time.now.iso8601
      }

      duration_seconds = @config.duration_minutes * 60
      current_time = 0.0
      person_id = 1

      while current_time < duration_seconds
        # Calculate next spawn time using exponential distribution
        next_spawn_delay = -Math.log(1.0 - Random.rand) / @config.user_spawn_rate
        current_time += next_spawn_delay

        break if current_time >= duration_seconds

        origin_floor = random_floor
        destination_floor = random_floor_excluding(origin_floor)

        @people << {
          "id" => person_id,
          "spawn_time" => current_time.round(1),
          "origin_floor" => origin_floor,
          "destination_floor" => destination_floor
        }

        person_id += 1
      end
    end

    def save_to_file(file_path)
      data = {
        "metadata" => @metadata,
        "people" => @people
      }

      File.write(file_path, JSON.pretty_generate(data))
    end

    private

    def random_floor
      # Simple uniform distribution for now
      Random.rand(@config.building_floors) + 1
    end

    def random_floor_excluding(exclude_floor)
      loop do
        floor = random_floor
        return floor unless floor == exclude_floor
      end
    end
  end
end
