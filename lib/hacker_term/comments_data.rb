require 'json'

module HackerTerm
  class CommentsData
    attr_reader :data

    def initialize(data)
      @data = JSON.parse data
    end
  end
end