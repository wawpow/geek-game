module Graphics
  class TrackedBot < Base
    alias :pew_pew :game_object

    def axis_length
      raise 'To be implemented in derived classes'
    end

    def draw_track(center, size)
      side_length = size.to_f
      corners = [Point(center.x - side_length / 2, center.y - side_length / 2),
                 Point(center.x + side_length / 2, center.y - side_length / 2),
                 Point(center.x + side_length / 2, center.y + side_length / 2),
                 Point(center.x - side_length / 2, center.y + side_length / 2)]
      corners.map! { |point| point.rotate_around(center, angle) }
      color = (size > 0) ? surface.default_color : [0xff, 0x00, 0x00]
      surface.rectangle(corners, color)
    end

    def draw_triangle(base)
      surface.triangle(Point(base.x - 2, base.y).rotate_around(base, angle),
                       Point(base.x, base.y + 4).rotate_around(base, angle),
                       Point(base.x + 2, base.y).rotate_around(base, angle),
                       player_color)
    end

    def draw_health_bar
      full_length = axis_length
      length = full_length * health_points.to_f / GeekGame::PewPew.max_health_points
      height = 3

      left_top = position.advance_by(Vector(-full_length.to_f / 2, full_length.to_f / 2 + 15))

      corners = [left_top,
                 left_top.advance_by(Vector(length, 0)),
                 left_top.advance_by(Vector(length, -height)),
                 left_top.advance_by(Vector(0, -height))
                ]
      surface.rectangle(corners)
    end

    def draw_battery_charge
      full_length = axis_length * 0.75
      actual_length = full_length * battery["charge"]
      width = 3

      left_bottom = position.advance_by(Vector(-axis_length / 2 - 10, -20))

      corners = [left_bottom,
                 left_bottom.advance_by(Vector(0, actual_length)),
                 left_bottom.advance_by(Vector(width, actual_length)),
                 left_bottom.advance_by(Vector(width, 0))
                ]
      surface.rectangle(corners, [128, 255, 128])
    end

    def left_track_position
      Point(*left_track_position_coordinates)
    end

    def right_track_position
      Point(*right_track_position_coordinates)
    end

    def track_axis
      Line left_track_position, right_track_position
    end

    def draw_axis
      surface.line track_axis, player_color
    end

    def draw
      draw_axis

      axis_vector = Vector(1, 0).rotate(angle)

      draw_triangle(position.advance_by(axis_vector * (axis_length / 4)))
      draw_triangle(position.advance_by(axis_vector * (axis_length / 4 * (-1))))

      draw_track(left_track_position, self.class.track_size * left_track_power)
      draw_track(right_track_position, self.class.track_size * right_track_power)

      draw_health_bar
      draw_battery_charge
    end
  end
end
