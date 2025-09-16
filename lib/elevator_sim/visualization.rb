# frozen_string_literal: true

require "tty-box"
require "tty-cursor"
require "tty-screen"
require "pastel"

module ElevatorSim
  # Real-time visualization for the elevator simulation
  class Visualization
    def initialize(building)
      @building = building
      @cursor = TTY::Cursor
      @screen = TTY::Screen
      @pastel = Pastel.new
      @previous_height = 0
    end

    def render_frame(simulation_state)
      clear_previous_frame

      content = build_frame_content(simulation_state)
      print content

      # Store height for next clear
      @previous_height = content.lines.count
    end

    def clear_screen
      print @cursor.clear_screen
      print @cursor.move_to(0, 0)
    end

    private

    def clear_previous_frame
      # Move cursor up and clear the previous frame
      if @previous_height > 0
        print @cursor.up(@previous_height)
        @previous_height.times { print @cursor.clear_line + "\n" }
        print @cursor.up(@previous_height)
      end
    end

    def build_frame_content(state)
      content = []

      # Header with simulation info
      content << build_header(state)
      content << ""

      # Building visualization
      content << build_building_view(state)
      content << ""

      # Statistics dashboard
      content << build_statistics_view(state)

      content.join("\n")
    end

    def build_header(state)
      time_str = sprintf("%.1fs", state[:time])
      elapsed = sprintf("%.1f", state[:time] / 60.0)

      header = @pastel.cyan.bold("🏢 Elevator Simulation") +
        @pastel.dim(" │ ") +
        @pastel.yellow("#{time_str} elapsed") +
        @pastel.dim(" (#{elapsed}min)")

      TTY::Box.frame(
        width: [@screen.width - 4, 60].min,
        border: :light,
        padding: 0
      ) { " " + header + " " }
    end

    def build_building_view(state)
      floors = @building.floor_range.to_a.reverse
      max_floor_width = floors.map(&:to_s).map(&:length).max

      building_lines = []

      floors.each do |floor|
        line = build_floor_line(floor, state, max_floor_width)
        building_lines << line
      end

      # Frame the building with manual padding
      building_content = building_lines.map { |line| " #{line} " }.join("\n")

      TTY::Box.frame(
        width: 62,  # Adjusted width: floor(8) + separators(6) + elevators(20) + people(25) + padding(3) = 62
        border: :light,
        title: {top_left: " Building View "},
        padding: 0
      ) { building_content }
    end

    def build_floor_line(floor, state, floor_width)
      floor_label = sprintf("Floor %#{floor_width}s", floor)
      floor_label = @pastel.dim(floor_label)

      # Get elevators on this floor
      elevators_on_floor = get_elevators_on_floor(floor, state)

      # Get people waiting on this floor
      people_count = count_people_waiting_on_floor(floor, state)

      # Build sections with exact fixed widths (calculate display width to handle colored text)
      elevator_section = pad_to_display_width(build_elevator_indicators(elevators_on_floor), 20)
      people_section = pad_to_display_width(build_people_indicators(people_count), 25)

      # Combine with exact spacing: floor(8) + " │ " + elevators(20) + " │ " + people(25) = 58 chars
      "#{floor_label} │ #{elevator_section} │ #{people_section}"
    end

    def get_elevators_on_floor(floor, state)
      state[:building].elevators.select do |elevator|
        # Check if elevator is at this floor (within 0.1 floors for movement)
        (elevator.current_floor - floor).abs < 0.1
      end
    end

    def count_people_waiting_on_floor(floor, state)
      state[:users].count do |user|
        user.state == :waiting_for_elevator && user.start_floor == floor
      end
    end

    def build_elevator_indicators(elevators)
      indicators = []

      # Show up to 4 elevators per floor, each taking exactly 4 display characters
      (1..4).each do |position|
        indicators << if (elevator = elevators[position - 1])
          pad_to_display_width(format_elevator_indicator(elevator), 4)
        else
          "    "  # Exactly 4 spaces
        end
      end

      # Join with single spaces to get exactly 19 display characters total
      indicators.join(" ")
    end

    def format_elevator_indicator(elevator)
      id = "E#{elevator.id}"

      case elevator.state
      when :moving_up
        @pastel.green("▲#{id}")
      when :moving_down
        @pastel.cyan("▼#{id}")
      when :doors_opening, :doors_closing
        @pastel.yellow("◉#{id}")
      when :idle
        if elevator.passengers.any?
          @pastel.blue("⬜#{id}")
        else
          @pastel.dim("⬜#{id}")
        end
      else
        @pastel.magenta("?#{id}")
      end
    end

    def build_people_indicators(count)
      if count == 0
        ""  # Empty - will be padded by ljust
      elsif count <= 5
        # Build the people string
        "👤" * count
      else
        "👤" * 5 + @pastel.dim("(#{count})")
      end
    end

    def build_statistics_view(state)
      stats = state[:statistics]

      lines = []
      lines << @pastel.bright_blue("📊 Live Statistics")
      lines << ""

      # Users stats
      total = stats[:total_users]
      completed = stats[:completed_users]
      completion_rate = (total > 0) ? (completed.to_f / total * 100) : 0

      lines << format_stat_line("👥 Users", "#{completed}/#{total}", completion_rate, "%")

      # Wait time
      wait_time = stats[:average_wait_time]
      wait_performance = calculate_wait_performance(wait_time)
      lines << format_stat_line("⏳ Avg Wait", "#{wait_time.round(1)}s", wait_performance, "%")

      # Utilization
      utilization = stats[:elevator_utilization] * 100
      lines << format_stat_line("📈 Utilization", "#{utilization.round(1)}%", utilization, "%")

      # Active calls
      call_count = state[:call_requests].length
      lines << format_simple_stat("📞 Active Calls", call_count.to_s)

      stats_content = lines.join("\n")

      TTY::Box.frame(
        width: [@screen.width - 4, 60].min,
        border: :light,
        title: {top_left: " Statistics "},
        padding: 0
      ) { " " + stats_content.gsub("\n", "\n ") + " " }
    end

    def format_stat_line(label, value, percentage, unit)
      bar = build_progress_bar(percentage)
      value_str = value.to_s.ljust(12)  # Fixed width for values
      "#{label.ljust(15)} #{bar} #{value_str}"
    end

    def format_simple_stat(label, value)
      # Don't try to pad colored text - just use fixed positioning
      colored_value = @pastel.bright_white(value.to_s)
      "#{label.ljust(15)} #{colored_value}"
    end

    def build_progress_bar(percentage, width = 10)
      filled = (percentage / 100.0 * width).round
      bar = "▓" * filled + "░" * (width - filled)

      color = case percentage
      when 0..30
        :red
      when 31..70
        :yellow
      else
        :green
      end

      @pastel.send(color, bar)
    end

    def calculate_wait_performance(wait_time)
      # Inverse performance: lower wait time = higher performance
      case wait_time
      when 0..5
        100
      when 5..15
        80
      when 15..30
        50
      when 30..60
        20
      else
        0
      end
    end

    def calculate_display_width(string)
      # Remove ANSI color codes and calculate display width
      clean_string = string.gsub(/\e\[[0-9;]*m/, "")

      # Count characters, treating emojis as 2 characters wide
      width = 0
      clean_string.each_char do |char|
        # Check if character is an emoji (rough approximation)
        width += if char.ord > 0x1F000
          2
        else
          1
        end
      end
      width
    end

    def truncate_to_width(string, max_width)
      # Simple truncation - could be improved for emoji handling
      if calculate_display_width(string) <= max_width
        string
      else
        # Crude truncation, might break emojis
        string[0...(max_width - 3)] + "..."
      end
    end

    def pad_to_display_width(string, target_width)
      current_width = calculate_display_width(string)
      if current_width >= target_width
        string
      else
        padding_needed = target_width - current_width
        string + (" " * padding_needed)
      end
    end
  end
end
