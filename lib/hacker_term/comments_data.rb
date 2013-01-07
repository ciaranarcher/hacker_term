require 'json'
require 'cgi'

module HackerTerm
  class CommentsData
    attr_reader :data

    def initialize(data)
      unescaped = CGI.unescapeHTML data
      @data = JSON.parse(unescaped)['items']
    end
  end
end