Pod::Spec.new do |s|
  s.name = 'SwiftWebViewJavascriptBridge'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'WKwebView java script bridge in Swift'
  s.homepage = 'https://github.com/NullWorld/SwiftWebViewJavascriptBridge'
  s.authors = { 'cy' => '815190226.com' }
  s.source = { :git => 'https://github.com/NullWorld/SwiftWebViewJavascriptBridge.git', :tag => s.version.to_s }

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'


  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => ‘3.0’,
  }

  s.requires_arc = true
  s.source_files = 'SwiftWebViewJavascriptBridge/*.swift'
end
