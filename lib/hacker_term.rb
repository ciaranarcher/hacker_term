require 'hacker_term/page_data'
require 'hacker_term/ui'
require 'rest_client'

module HackerTerm
  class TerminalApp
    def initialize
      @raw_json = read_json
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

    def read_json
      local_proxy = get_local_proxy
      RestClient.proxy = local_proxy unless local_proxy.empty?
      RestClient.get 'http://hndroidapi.appspot.com/news/format/json/page/'
    end

    def get_local_proxy
      # Cater for both upper and lower case env variables

      local_proxy = `echo $http_proxy`.chomp
      return local_proxy unless local_proxy.empty?

      `echo $HTTP_PROXY`.chomp
    end

    def clear_and_show
      @ui.clear!
      @ui.show @page
    end
  end
end