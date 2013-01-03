require 'json'
require 'cgi'

module HackerTerm
  class CommentsData
    attr_reader :data

    def initialize(data)
      unescaped = CGI.unescapeHTML data
      @data = JSON.parse(unescaped)['items']
    end

    def data_as_text(max_width)
      @data.each do |line|
         # words = line['comment'].split ' '
         # new_line = ''
         # words.inject(0) do |length, word| 
         #  length + word.length + 1 
         #  wor
         #  if length >= max_width
         #    length = 0 

         #  end
         # end
      end
    end
  end
end