$:.unshift(File.dirname(__FILE__) + '/lib')

require 'hacker_term'
app = HackerTerm::TerminalApp.new
app.run!