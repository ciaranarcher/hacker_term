require 'hacker_term/page_data'
require 'hacker_term/ui'
require 'rest_client'
require 'launchy'
require 'clipboard'

module HackerTerm
  class TerminalApp
    def initialize
      @raw_json = read_json
      load
    end

    def run!
      clear_and_show

      begin
        char = @ui.get_char

        case char.to_s.upcase.chomp
        when "Q"
          @ui.close
          exit
        
        when "UP"
          @page.change_line_pos :down
        
        when "DOWN"
          @page.change_line_pos :up
        
        when "K"
          @page.change_line_pos :down

        when "J"
          @page.change_line_pos :up

        when "O"
          open_link(@page.selected_url)
          
        when "D"
          open_link(@page.selected_comments_url)
        
        when "A"
          load
          @page.change_line_pos :reset
        
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

      0 # Zero exit code means everything was OK...
    end

    private

    def open_link(url)
      # Attempts to launch a browser; writes URL to clipboard in any case
      begin
        Launchy.open url # May not work in some Linux flavors
      rescue
      ensure
        Clipboard.copy url
      end
    end

    def load
      @page = PageData.new @raw_json
      @ui = UI.new
    end

    def read_json
      local_proxy = get_local_proxy
      RestClient.proxy = local_proxy unless local_proxy.nil?
      RestClient.get 'http://hndroidapi.appspot.com/news/format/json/page/'
    end

    def get_local_proxy
      # Cater for both upper and lower case env variables
      local_proxy = ENV['HTTP_PROXY']
      return local_proxy unless local_proxy.nil?
      ENV['http_proxy']
    end

    def clear_and_show
      @ui.clear!
      @ui.show @page
    end
  end
end
