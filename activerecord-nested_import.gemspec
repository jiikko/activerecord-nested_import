# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/nested_import/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-nested_import"
  spec.version       = Activerecord::NestedImport::VERSION
  spec.authors       = ["jiikko"]
  spec.email         = ["n905i.1214@gmail.com"]

  spec.summary       = %q{activerecord-nested_import is activerecord-import wrapper. can bulk insert "has_many through" association. }
  spec.description   = %q{activerecord-nested_import is activerecord-import wrapper. can bulk insert "has_many through" association.}
  spec.homepage      = "https://github.com/jiikko/activerecord-nested_import"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.1"
  gem.add_runtime_dependency "activerecord-import", ">= 0.9"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
