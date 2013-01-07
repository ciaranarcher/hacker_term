require 'curses'

module HackerTerm
  class UI
    include Curses

    def initialize(opts={})

      opts = defaults.merge(opts) # Ununsed for now

      raw # Intercept everything
      noecho # Do not echo user input to stdout
      stdscr.keypad(true) # Enable arrows

      if can_change_color?
        start_color
        # foreground / background colours
        init_pair(0, COLOR_WHITE, COLOR_BLACK)
        init_pair(1, COLOR_WHITE, COLOR_BLUE)
        init_pair(2, COLOR_WHITE, COLOR_RED)
        init_pair(3, COLOR_BLACK, COLOR_GREEN)
      end

      @total_width = cols
      @total_height = lines
      @padding_left = 2
      @title_width = 0
      @cols  = ['rank', 'title', 'score', 'comments']
      @line_num = -1

      clear!
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

    def output_divider(line_num)
      setpos(line_num, 0)
      attrset color_pair(0)
      addstr('-' * @total_width)
    end

    def <<(str)
      throw 'invalid type' unless str.is_a? String
      output_line(next_line_num, str) 
    end

    def divider
      output_divider(next_line_num) 
    end

    def output(&blk)
      blk.call self if block_given?
    end

    def draw_header
      output do |buff|
        buff.divider
        attrset color_pair(1)
        buff << "HACKER NEWS TERMINAL - thanks to http://hndroidapi.appspot.com"
        buff << "CMDS: Select (Arrows), Open Item (O), Open Item Discussion (D), Refresh (A)"
        buff << "CMDS CONT: Sort by Rank (R), Score (S), Comments (C), Title (T) | Quit (Q)"
        buff.divider

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
        buff << "RANK | TITLE " + " " * (@total_width - width_excl_title) + "| SCORE | COMMENTS"
        buff.divider
      end
    end

    def draw_footer(sorted_by, mean, median, mode)
      output_divider(next_line_num) 
      attrset color_pair(1)
      formatted = sprintf("Sorted by: %7s | Scores: Mean: %4.2f | Median: %4.2f | Mode: %4.2f", 
        sorted_by, mean, median, mode)
      output_line(next_line_num, formatted)
      output_divider(next_line_num) 
    end

    def draw_item_line(rank, data, selected)

      begin
        # Truncate if too long
        title = truncate_line! data

        # Format and output
        if selected
          rank = '> ' + rank
          attrset color_pair(3)
        else
          attrset color_pair(0)
        end

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
        draw_item_line(line_data['rank'], line_data, page_data.line_pos == i + 1) 
      end

      draw_footer(page_data.sorted_by, 
        page_data.mean_score, 
        page_data.median_score, 
        page_data.mode_score
      )
    end

    def get_char
      interpret_char(getch)
    end

    def interpret_char(c)
      case c
      when Curses::Key::UP
        'up'
      when Curses::Key::DOWN
        'down'
      else
        c
      end
    end

    def close
      close_screen
    end

    def clear!
      setpos(0, 0)
      clear
    end

    private

    def defaults
      @options ||= {}
    end
  end
end