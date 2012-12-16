require_relative 'lib/hacker_term'
require 'json'

data = JSON.parse(File.read './data/data.json')['items']
config = {
  :column_headers => data.first.keys.keep_if { |k| ['title', 'score', 'comments']}
}

win = HackerTerm::UI.new(config)
win.show data