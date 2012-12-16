require_relative 'lib/hacker_term'
require 'json'

data = JSON.parse(File.read './data/data.json')['items']
config = {
  :column_headers => data.first.keys
}

win = HackerTerm::UI.new(config)
win.show