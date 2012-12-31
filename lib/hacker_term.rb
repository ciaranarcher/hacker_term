require 'hacker_term/page_data'
require 'hacker_term/ui'

module HackerTerm
  class TerminalApp
    def self.run


      #$stdout.reopen('/dev/null', 'w') # Not sure if I'm going to need this yet...
      page = PageData.new File.read './data/data.json' 
      ui = UI.new
      ui.clear!
      ui.show page

      begin
        char = ui.get_char

        case char.to_s.upcase.chomp
        when "27" # Esc
          ui.close
          break
        when "S"
          page.sort_on!(:score)
        when "R"
          page.sort_on!(:rank)
        when "T"
          page.sort_on!(:title)
        when "C"
          page.sort_on!(:comments)
        end

        ui.clear!
        ui.show page

      end while true
    end
  end
end