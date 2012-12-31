$:.unshift(File.dirname(__FILE__) + '/lib')

require 'hacker_term'

page = HackerTerm::PageData.new File.read './data/data.json' 
win = HackerTerm::UI.new
win.show page
