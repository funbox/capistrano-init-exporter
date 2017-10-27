lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'init_exporter/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-init-exporter'
  spec.version       = InitExporter::VERSION
  spec.authors       = ['funbox']
  spec.email         = ['a.ilyin@fun-box.ru', 'i.kushmantsev@fun-box.ru']

  spec.summary       = 'Capistrano bindings for exporting services described by Procfile to init system'
  spec.homepage      = 'https://github.com/funbox/capistrano-init-exporter'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('capistrano', '~> 3.0')

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
