require 'curses'

# HACKER NEWS
# Arrow keys to select | Enter to open | F5 to refresh
# rank | title                   | url         | score | comments
# 1    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 230   | 8
# 2    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 29    | 0
# 3    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 2     | 2
# 4    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 45    | 6
# 5    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 25    | 1
# 6    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 98    | 80
# 7    | xxxxxxxxxxxxxxxxxxxx... | xxxxxxxx... | 280   | 5
# Sorted by: score | Mean: x | Median: x | Mode x 
# Q:quit | R:sort/rank | T: sort/title | S:sort/score | C: sort/ comment  

module HackerTerm
  class UI

    include Curses

    

    def initialize(config={})
      if can_change_color?
        start_color
        # foreground / background colours
        init_pair(0, COLOR_WHITE, COLOR_BLACK)
        init_pair(1, COLOR_WHITE, COLOR_BLUE)
        init_pair(2, COLOR_WHITE, COLOR_RED)
      end

      @total_width = cols
      @total_height = lines
      @padding_left = 2
      @cols  = ['rank', 'title', 'score', 'comments']
    end

    def output_line(line_num, data)
      setpos(line_num, 0)
      padding_right = @total_width - data.length - @padding_left
      padding_right = 0 if padding_right < 0
      addstr((" " * @padding_left) + data + (" " * padding_right))
    end

    def draw_header()
      attrset color_pair(1)
      output_line(0, "HACKER NEWS (Thanks to http://hndroidapi.appspot.com/)") 
      output_line(1, "Arrow keys to select | Enter to open | F5 to refresh")

      # Get width_excl_title, i.e. width of all columns + some extra for |'s and spacing.
      # Once obtained, pad out the title column with the any width remaining
      # A nicer way to do this is always put the title last, and assume last column gets
      # remaining width. That way we can just loop through our cols, rather than hardcoding
      # them as per example below. I'm sticking to this because I want the title listed second.
      width_excl_title = @cols.inject(0) do |width, col| 
        width += (3 + col.length)
      end
      attrset color_pair(2)
      output_line(2, "rank | title " + " " * (@total_width - width_excl_title) + "| score | comments")
    end

    def draw_footer(sorted_by, stats, key_options)
      
    end

    def draw_item_line(rank, data)
    end

    def show(data)
      draw_header
      getch
      close_screen
    end
  end
end


