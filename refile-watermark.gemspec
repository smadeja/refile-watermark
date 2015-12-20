# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'refile/watermark/version'

Gem::Specification.new do |spec|
  spec.name          = "refile-watermark"
  spec.version       = Refile::Watermark::VERSION
  spec.authors       = ["Will Bradley"]
  spec.email         = ["will@zyphon.com"]
  spec.summary       = "Refile plugin to use MiniMagick for watermarking"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "refile", "~> 0.5"
  spec.add_dependency "mini_magick", "~> 4.0"
  spec.add_dependency "refile-mini_magick", "~> 0.2"
end
