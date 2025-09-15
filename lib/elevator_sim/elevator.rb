# frozen_string_literal: true

module ElevatorSim
  class Elevator
    attr_reader :id, :capacity, :speed, :door_open_time, :door_close_time, :service_floors
    attr_reader :current_floor, :passengers, :state, :target_floor

    STATES = %i[idle moving_up moving_down doors_opening doors_closing].freeze

    def initialize(id:, capacity:, speed:, door_open_time:, door_close_time:, service_floors:)
      @id = id
      @capacity = capacity
      @speed = speed
      @door_open_time = door_open_time
      @door_close_time = door_close_time
      @service_floors = service_floors

      @current_floor = service_floors.first
      @passengers = []
      @state = :idle
      @target_floor = nil
      @state_timer = 0.0
    end

    def can_service_floor?(floor)
      @service_floors.include?(floor)
    end

    def available_capacity
      @capacity - @passengers.length
    end

    def full?
      @passengers.length >= @capacity
    end

    def empty?
      @passengers.empty?
    end

    def idle?
      @state == :idle
    end

    def moving?
      %i[moving_up moving_down].include?(@state)
    end

    def doors_open?
      @state == :doors_opening
    end

    def doors_closed?
      !doors_open?
    end

    def move_to_floor(floor)
      return false unless can_service_floor?(floor)
      return true if @current_floor == floor

      @target_floor = floor
      @state = (floor > @current_floor) ? :moving_up : :moving_down
      true
    end

    def open_doors
      return false unless doors_closed?

      @state = :doors_opening
      @state_timer = @door_open_time
      true
    end

    def close_doors
      return false unless doors_open?

      @state = :doors_closing
      @state_timer = @door_close_time
      true
    end

    def add_passenger(passenger)
      return false if full?

      @passengers << passenger
      true
    end

    def remove_passengers_for_floor(floor)
      passengers_leaving = @passengers.select { |p| p[:destination_floor] == floor }
      @passengers.reject! { |p| p[:destination_floor] == floor }
      passengers_leaving
    end

    def update(time_delta)
      case @state
      when :moving_up, :moving_down
        update_movement(time_delta)
      when :doors_opening, :doors_closing
        update_doors(time_delta)
      end
    end

    def to_s
      status = case @state
      when :idle then "Idle"
      when :moving_up then "↑"
      when :moving_down then "↓"
      when :doors_opening then "◉"
      when :doors_closing then "◉"
      end

      "E#{@id}[#{status}] Floor #{@current_floor} (#{@passengers.length}/#{@capacity})"
    end

    def status
      {
        id: @id,
        current_floor: @current_floor,
        target_floor: @target_floor,
        state: @state,
        passengers: @passengers.length,
        capacity: @capacity,
        available_capacity: available_capacity,
        service_floors: @service_floors
      }
    end

    private

    def update_movement(time_delta)
      return unless @target_floor

      floors_per_second = @speed
      distance = (@target_floor - @current_floor).abs
      time_to_target = distance / floors_per_second

      if time_delta >= time_to_target
        @current_floor = @target_floor
        @target_floor = nil
        @state = :idle
      else
        # Partial movement
        floors_moved = floors_per_second * time_delta
        direction = (@target_floor > @current_floor) ? 1 : -1
        @current_floor += (floors_moved * direction)
      end
    end

    def update_doors(time_delta)
      @state_timer -= time_delta

      if @state_timer <= 0
        case @state
        when :doors_opening
          @state = :idle # Doors are now open
        when :doors_closing
          @state = :idle # Doors are now closed
        end
        @state_timer = 0.0
      end
    end
  end
end
