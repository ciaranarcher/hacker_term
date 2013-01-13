require 'json'
require 'cgi'

module HackerTerm
  class CommentsData
    include Enumerable
    attr_reader :data

    def initialize(data='')
      @data = []
      return if data.empty?
      
      begin 
        @data = JSON.parse(data)['items']
      rescue JSON::ParserError
        raise "JSON appears to be malformed: #{data}" # Bomb out for now...
      end

      unescape_titles!
      replace_breaks!
    end

    def unescape_titles!
      @data.each { |row| row['comment'] = CGI.unescapeHTML(row['comment']) }
    end

    def replace_breaks!
      @data.each { |row| row['comment'] = row['comment'].gsub("__BR__", "\n\n") }
    end

    def data_as_text(max_width)
      all = []
      @data.each do |line|
        # Split lines into words
        words = line['comment'].split ' '
        all << fit_words_to_width(words, max_width)
      end

      all.join
    end

    def fit_words_to_width(arr_words, max_width)
      new_lines = []
      char_counter = 0

      arr_words.each do |w|
        # If we see that a line is going to end up too long, add a newline
        char_counter += w.length + 1 # +1 for the space
        
        if char_counter > max_width
          new_lines << "\n" + w + ' '
          char_counter = 0
        else
          new_lines << w + ' '
        end
      end

      new_lines.join
    end

    def each(&blk)
      @data.each do |comment| 
        blk.call({
          :username => comment['username'],
          :comment => comment['comment'],
          :time =>  comment['time'],
        }) 
      end
    end
  end
end