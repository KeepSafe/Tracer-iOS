Pod::Spec.new do |spec|
  spec.name         = "Tracer"
  spec.summary      = "Use traces to validate UX flows, analytics, or event buses."
  spec.version      = "0.1.0"
  spec.homepage     = "https://github.com/KeepSafe/Tracer-iOS"
  spec.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  spec.authors      = { "Keepsafe" => "rob@getkeepsafe.com" }
  spec.source       = { :git => "https://github.com/KeepSafe/Tracer-iOS.git", :tag => "v" + spec.version.to_s }
  spec.source_files = "Source/**/*"
  spec.ios.deployment_target = "10.0"
  spec.requires_arc = true
end