# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attr_typed/version'

Gem::Specification.new do |spec|
  spec.name          = "attr_typed"
  spec.version       = AttrTyped::VERSION
  spec.authors       = ["Anthony Langhorne"]
  spec.email         = ["anthony.langhorne@ferocia.com.au"]

  spec.summary       = %q{Enforce attribute types at assignment time}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'monetize', '>= 1.0.0'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end