# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'site_dumper/version'

Gem::Specification.new do |spec|
  spec.name          = "site_dumper"
  spec.version       = SiteDumper::VERSION
  spec.authors       = ["Pavel Naydenov"]
  spec.email         = ["naydenov.p.v@gmail.com"]

  spec.summary       = %q{SiteDumper creates dump of site including database and user files and sends it to the admin email}
  spec.description   = %q{SiteDumper creates dump of site including database and user files and sends it to the admin email}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.post_install_message = "Run 'rails g site_dumper:install' for complete installation"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 3"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
