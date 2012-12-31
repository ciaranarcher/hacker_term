$:.unshift(File.dirname(__FILE__) + '/lib')

require 'page_data'
require 'ui'

page = HackerTerm::PageData.new File.read './data/data.json' 
win = HackerTerm::UI.new
win.show page
