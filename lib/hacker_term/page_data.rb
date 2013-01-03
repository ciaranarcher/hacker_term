require 'json'

# Controversial monkeypatch of String class so it can tell us if a string is a number
class String
  def is_num?
    self =~ /^[-+]?[0-9]*\.?[0-9]+$/
  end
end

module HackerTerm
  class PageData
    attr_reader :data, :mean_score, :median_score, :mode_score, :sorted_by, :line_pos

    def initialize(data)
      @data = JSON.parse(data)['items']
      
      add_missing_keys!
      format_numbers!
      format_urls!
      
      calculate_mean_score
      calculate_median_score
      calculate_mode_score

      @sorted_by = 'RANK'
      @line_pos = 1
    end

    def sort_on!(mode)
      case mode
      when :score
        @data = @data.sort_by { |a| -a['score'].to_f } # desc
      when :comments
        @data = @data.sort_by { |a| -a['comments'].to_f } # desc
      when :rank
        @data = @data.sort_by { |a| a['rank'].to_f }
      when :title
        @data = @data.sort_by { |a| a['title'].upcase }
      else
        throw "Sorting mode #{mode} not supported!"
      end

      @sorted_by = mode.to_s.upcase
    end

    def change_line_pos(direction)
      if direction == :up
        @line_pos += 1 unless @line_pos == @data.length
      elsif direction == :down
        @line_pos -= 1 unless @line_pos == 1
      elsif direction == :reset
        @line_pos = 1
      end
    end

    def selected_url
      @data[@line_pos - 1]['url']
    end
    
    def selected_comments_url
      "http://news.ycombinator.com/item?id=" + @data[@line_pos - 1]['item_id']
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
      counter = 1
      @data.each do |item|

        # Add rank (so we can re-sort in 'natural' order)
        unless item.has_key? 'rank'
          item['rank'] = counter.to_s
        end

        unless item.has_key? 'score'
          item['score'] = '0'
        end

        unless item.has_key? 'comments'
          item['comments'] = '0'
        end

        counter += 1
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

    def format_urls!
      # Add HN domain for posts without an external link
      @data.each do |item|
        item['url'] = "http://news.ycombinator.com/#{item['url']}" if item['url'] =~ /^item\?id=[0-9]+/
      end
    end

  end
end
