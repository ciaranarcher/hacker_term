require 'hacker_term/page_data'
require 'hacker_term/ui'

module HackerTerm
  class TerminalApp
    def self.run
      page = PageData.new File.read './data/data.json' 
      win = UI.new
      win.show page
    end
  end
end