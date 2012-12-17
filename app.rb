$:.unshift(File.dirname(__FILE__) + '/lib')

require 'hacker_term'
require 'json'

data = JSON.parse(File.read './data/data.json')['items']

win = HackerTerm::UI.new
win.show data