# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/fta_version'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-fta"
  spec.version       = Kitchen::Driver::FTA_VERSION
  spec.authors       = ["DaRT"]
  spec.email         = ["dart@bestbuy.com"]
  spec.description   = %q{A FTA driver for Test Kitchen}
  spec.summary       = %q{A FTA driver for Test Kitchen}
  spec.homepage      = ""
  spec.license       = "Apache"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'test-kitchen', '~> 1.0.0.beta'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yarjuf'

end
