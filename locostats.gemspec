Gem::Specification.new do |spec|

  spec.platform = Gem::Platform::RUBY
  spec.name        = 'locostats'
  spec.version     = '0.1'
  spec.summary     = 'Ruby libraries for PsychoStats'
  spec.description = 'locostats contains a bunch of ruby libraries designed to interact with PsychoStats, for example, some ActiveRecord bindings'

  spec.author   = 'Andrius Bentkus'
  spec.email    = 'ToXedVirus@gmail.com'
  spec.homepage = 'http://www.github.com/txdv/locostats/'

  spec.bindir             = 'bin/'
  spec.executables        = ['locostats']
  spec.default_executable = 'locostats'

  spec.files =  Dir['bin/*']
  spec.files += Dir['lib/*']
  spec.files += Dir['lib/locostats/*']
  spec.files += Dir['lib/locostats/activerecord/*']

  spec.has_rdoc = false
  spec.add_dependency 'activerecord', '>= 3.0.0'
end
