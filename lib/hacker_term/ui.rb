require 'curses'

# HACKER NEWS
# Arrow keys to select | Enter to open | F5 to refresh
# rank | title                   | score | comments
# 1    | xxxxxxxxxxxxxxxxxxxx... | 230   | 8
# 2    | xxxxxxxxxxxxxxxxxxxx... | 29    | 0
# 3    | xxxxxxxxxxxxxxxxxxxx... | 2     | 2
# 4    | xxxxxxxxxxxxxxxxxxxx... | 45    | 6
# 5    | xxxxxxxxxxxxxxxxxxxx... | 25    | 1
# 6    | xxxxxxxxxxxxxxxxxxxx... | 98    | 80
# 7    | xxxxxxxxxxxxxxxxxxxx... | 280   | 5
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
      @title_width = 0
      @cols  = ['rank', 'title', 'score', 'comments']
      @line_num = -1
    end

    def next_line_num
      @line_num += 1
    end

    def output_line(line_num, data)
      setpos(line_num, 0)
      padding_right = @total_width - data.length - @padding_left
      padding_right = 0 if padding_right < 0  
      addstr((" " * @padding_left) + data + (" " * padding_right))
    end

    def draw_header
      attrset color_pair(1)
      output_line(next_line_num, "HACKER NEWS (Thanks to http://hndroidapi.appspot.com/)") 
      output_line(next_line_num, "Arrow keys to select | Enter to open | F5 to refresh")

      # Get width_excl_title, i.e. width of all columns + some extra for |'s and spacing.
      # Once obtained, pad out the title column with the any width remaining
      # A nicer way to do this is always put the title last, and assume last column gets
      # remaining width. That way we can just loop through our cols, rather than hardcoding
      # them as per example below. I'm sticking to this because I want the title listed second.
      width_excl_title = @cols.inject(0) do |width, col| 
        width += (3 + col.length)
      end
      attrset color_pair(2)
      @title_width = @total_width - width_excl_title + 'title'.length
      output_line(next_line_num, "rank | title " + " " * (@total_width - width_excl_title) + "| score | comments")
    end

    def draw_footer(sorted_by='rank', mean, median, mode)
      attrset color_pair(1)
      formatted = sprintf("Sorted by: %7s | Scores: Mean: %4.2f | Median: %4.2f | Mode: %4.2f", 
        sorted_by, mean, median, mode)
      output_line(next_line_num, formatted)
    end

    def draw_item_line(rank, data)
      attrset color_pair(0)

      begin
        # Truncate if too long
        title = truncate_line! data

        # Format and output
        formatted = sprintf("%4s | %-#{@title_width}s | %5s | %8s", rank, title, data['score'], data['comments'])
        output_line(next_line_num, formatted)
      rescue => ex
        p "error: #{ex.to_s}"
      end
    end

    def truncate_line!(data)
      return data['title'][0, @title_width - 3] + '...' if data['title'].length >= @title_width
      data['title']
    end

    def show(page_data)
      draw_header

      page_data.data.each_index do |i| 
        line_data = page_data.data.fetch(i)
        draw_item_line(line_data['rank'].to_i, line_data) 
      end

      draw_footer(page_data.mean_score, page_data.median_score, page_data.mode_score)

      getch
      close_screen
    end
  end
end