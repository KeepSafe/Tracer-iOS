Pod::Spec.new do |spec|
  spec.name         = 'Tracer'
  spec.summary      = 'Use traces to validate UX flows, analytics, or event buses.'
  spec.version      = '0.1.2'
  spec.homepage     = 'https://github.com/KeepSafe/Tracer-iOS'
  spec.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.authors      = { 'Keepsafe' => 'rob@getkeepsafe.com' }
  spec.source       = { :git => 'https://github.com/KeepSafe/Tracer-iOS.git', :tag => "v" + spec.version.to_s }
  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true
  spec.swift_version = '4.2'
  
  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'Source/**/*.{h,swift}'
  end
  
  spec.subspec 'UI' do |subspec|
    subspec.dependency 'Tracer/Core'
    subspec.source_files = 'UI/**/*.{swift}'
    subspec.resource = 'UI/TraceUI.xcassets'
  end
end