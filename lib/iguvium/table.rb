# frozen_string_literal: true

module Iguvium
  class Table
    def initialize(box, page)
      @box = box
      @lines = page.lines
      @characters = page.characters
    end

    attr_reader :characters, :lines, :box

    def to_a
      grid[:rows]
        .reverse
        .map { |row| grid[:columns].map { |column| render chars_inside(column, row) } }
    end

    def to_csv
      to_a.map(&:to_csv).join
    end

    private

    def grid
      @grid ||=
        {
          rows: lines_to_ranges(lines[:horizontal]),
          columns: lines_to_ranges(lines[:vertical])
        }
    end

    def lines_to_ranges(lines)
      lines.select { |line| line_in_box?(line, box) }
           .map { |line| line.first.is_a?(Numeric) ? line.first : line.last }
           .sort
           .each_cons(2)
           .map { |a, b| a...b }
    end

    def line_in_box?(line, box)
      line = line.map { |coord| coord.is_a?(Range) ? coord.to_a.minmax : [coord] }
      (
      line.first.map { |coord| box.first.cover?(coord) } +
          line.last.map { |coord| box.last.cover?(coord) }
    ).all?
    end

    def chars_inside(xrange, yrange)
      characters.select { |character|
        xrange.cover?(character.x) && yrange.cover?(character.y)
      }
    end

    def render(characters)
      characters
        .sort
        .chunk_while { |a, b| a.mergable?(b) }
        .map { |chunk| chunk.inject(&:+).to_s }
        .join("\n")
    end
  end
end