# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hacker_term/version'

Gem::Specification.new do |gem|
  gem.name          = "hacker_term"
  gem.version       = HackerTerm::VERSION
  gem.authors       = ["Ciaran Archer"]
  gem.email         = ["ciaran.archer@gmail.com"]
  gem.description   = %q{Read Hacker News on the Terminal}
  gem.summary       = %q{Allows the reading, sorting and opening of HN articles from the terminal.}
  gem.homepage      = "https://github.com/ciaranarcher/hacker_term"
  gem.add_dependency('rest-client')
  gem.add_dependency('launchy')
  gem.add_dependency('clipboard')
  gem.add_development_dependency('rspec')
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
