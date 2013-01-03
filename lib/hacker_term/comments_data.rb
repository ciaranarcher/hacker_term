require 'json'
<<<<<<< HEAD
require 'cgi'
=======
>>>>>>> 7e1ec95... Parsing comments data

module HackerTerm
  class CommentsData
    attr_reader :data

    def initialize(data)
<<<<<<< HEAD
      unescaped = CGI.unescapeHTML data
      @data = JSON.parse(unescaped)['items']
=======
      @data = JSON.parse data
>>>>>>> 7e1ec95... Parsing comments data
    end
  end
end