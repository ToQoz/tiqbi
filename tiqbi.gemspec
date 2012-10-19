# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tiqbi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Takatoshi Matsumoto"]
  gem.email         = ["toqoz403@gmail.com"]
  gem.description   = "text - mode interface for qiita"
  gem.summary       = "tiqbi"
  gem.homepage      = "https://github.com/ToQoz/tiqbi"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tiqbi"
  gem.require_paths = ["lib"]
  gem.version       = Tiqbi::VERSION

  gem.add_dependency "slop"
  gem.add_dependency "qiita", ">= 0.0.3"
  gem.add_dependency "sanitize"
end
