Pod::Spec.new do |s|
  s.name             = 'FSFunctionStatistics'
  s.version          = '1.0.0'
  s.summary          = 'A short description of FSFunctionStatistics.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/kinarobin/FSFunctionStatistics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kinarobin' => 'kinarobin@outlook.com' }
  s.source           = { :git => 'https://github.com/kinarobin/FSFunctionStatistics.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'FSFunctionStatistics/Classes/**/*'

end
