#!/opt/rubies/rbx-2.2.6/bin/gem build

Gem::Specification.new do |s|
  s.name              = 'rspec-sane-http'
  s.version           = '0.0.1'
  s.date              = Date.today.to_s
  s.authors           = ['https://github.com/botanicus']
  s.summary           = 'YYY'
  s.description       = 'XXX'
  s.email             = 'james@101ideas.cz'
  s.homepage          = 'https://github.com/botanicus/rspec-sane-http'
  s.rubyforge_project = s.name
  s.license           = 'MIT'

  s.files             = ['README.md', *Dir.glob('**/*.rb')]

  s.add_runtime_dependency('http', '~> 0')
end
