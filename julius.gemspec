# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'julius/version'

Gem::Specification.new do |gem|
  gem.name          = "julius"
  gem.version       = Julius::VERSION
  gem.authors       = ["Hajime WAKAHARA"]
  gem.email         = ["hajime.wakahara@gmail.com"]
  gem.description   = %q{Get results from module mode Julius.}
  gem.summary       = %q{A wrapper for Julius, the Open-Source Large Vocabulary CSR Engine}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
