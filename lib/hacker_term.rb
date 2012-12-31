require 'hacker_term/page_data'
require 'hacker_term/ui'

module HackerTerm
  class TerminalApp
    def initialize
      @raw_json = File.read './data/data.json'
      @page = PageData.new @raw_json
      @ui = UI.new
    end

    def run
      #$stdout.reopen('/dev/null', 'w') # Not sure if I'm going to need this yet...
      
      clear_and_show

      begin
        char = @ui.get_char

        case char.to_s.upcase.chomp
        when "27" # Esc
          @ui.close
          break
        when "S"
          @page.sort_on!(:score)
        when "R"
          @page.sort_on!(:rank)
        when "T"
          @page.sort_on!(:title)
        when "C"
          @page.sort_on!(:comments)
        end

       clear_and_show

      end while true
    end

    private

    def clear_and_show
      @ui.clear!
      @ui.show @page
    end
  end
end