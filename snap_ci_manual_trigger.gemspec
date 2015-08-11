# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snap_ci_manual_trigger/version'

Gem::Specification.new do |spec|
  spec.name          = 'snap_ci_manual_trigger'
  spec.version       = SnapCiManualTrigger::VERSION
  spec.authors       = ['Eduardo Turiño']
  spec.email         = ['eturino@eturino.com']

  spec.summary       = %q{Helps triggering specific steps on Snap-CI using API}
  spec.homepage      = 'https://github.com/artirix/snap_ci_manual_trigger'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'
  spec.add_dependency 'oj'
  spec.add_dependency 'oj_mimic_json'

  spec.add_dependency 'rake' # for the generators
  spec.add_dependency 'railties', '>= 3.2', '< 5' # for the generators

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'stub_env'
  spec.add_development_dependency 'generator_spec'
end
