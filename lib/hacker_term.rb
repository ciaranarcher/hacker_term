require 'curses'
require 'json'

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


# Controversial monkeypatch of String class so it can tell us if a string is a number
class String
  def is_num?
    self =~ /^[-+]?[0-9]*\.?[0-9]+$/
  end
end

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
      page_data.data.each_index { |i| draw_item_line(i + 1, page_data.data.fetch(i))}
      draw_footer(page_data.mean_score, page_data.median_score, page_data.mode_score)
      getch
      close_screen
    end
  end

  class PageData
    attr_reader :data, :mean_score, :median_score, :mode_score

    def initialize(data)
      @data = JSON.parse(data)['items']
      
      add_missing_keys!
      format_numbers!
      
      calculate_mean_score
      calculate_median_score
      calculate_mode_score
    end

    def sort_on!(mode)
      case mode
      when :score
        @data = @data.sort do |a, b|
          a['score'].to_f <=> b['score'].to_f
        end
      else
        throw "sorting mode #{mode} not supported"
      end
    end

    private

    def calculate_mode_score
      freq = @data.inject(Hash.new(0)) { |h,v| h[v['score'].to_f] += 1; h }
      # Call sort_by on hash to create an array which each contains two elements, the key and value
      # So we grab the last item, and return the 'key' from our original hash
      @mode_score = freq.sort_by { |k, v| v }.last.first
    end

    def calculate_mean_score
      @mean_score = @data.inject(0.0) { |sum, el| sum + el['score'].to_f } / @data.size
    end

    def calculate_median_score
      # Read our numbers and sort them first
      sorted_scores = @data.map { |el| el['score'].to_f }.sort
      len = sorted_scores.length
      @median_score = len % 2 == 1 ? sorted_scores[len / 2] : (sorted_scores[len / 2 - 1] + sorted_scores[len / 2]).to_f / 2
    end

    def add_missing_keys!
      # Here we're looking to fix nodes with missing/incorrect data
      @data.each do |item|
        unless item.has_key? 'score'
          item['score'] = '0'
        end

        unless item.has_key? 'comments'
          item['comments'] = '0'
        end
      end
    end

    def format_numbers!
      # Assumption here is a format like '10 comments' or '35 points'
      # Also chucks anything left over that isn't a number
      @data.each do |item|
        item['comments'] = item['comments'].split(' ').first if item['comments'].include? ' '
        item['comments'] = '0' unless item['comments'].is_num?
        item['score'] = item['score'].split(' ').first if item['score'].include? ' '
        item['score'] = '0' unless item['score'].is_num?
      end
    end
  end
end