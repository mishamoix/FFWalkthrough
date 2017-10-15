Pod::Spec.new do |s|
s.name             = 'FFWalkthrough'
s.version          = '0.1.0'
s.summary          = 'Walkthrough which allow make highlighted yours elements'

s.description      = <<-DESC
Walkthrough which allow make highlighted yours elements. it's look fantastic!
DESC

s.homepage         = 'https://github.com/mishamoix/FFWalkthrough'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'mishamoix' => 'mishamoix28@gmail.com' }
s.source           = { :git => 'https://github.com/mishamoix/FFWalkthrough.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'
s.source_files = 'FFWalkthrough/*'

end
