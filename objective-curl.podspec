Pod::Spec.new do |s|
  s.name         = "objective-curl"
  s.version      = "0.0.1"
  s.summary      = "Curl bindings for Objective-C."
  s.homepage     = "https://github.com/nrj/objective-curl"
  s.license      = 'MIT'
  s.author       = { "Nick Jensen" => "nickrjensen@gmail.com" }
  s.source       = { :git => "https://github.com/nrj/objective-curl.git", :tag => "0.0.1" }
  s.platform     = :osx, '10.7'
  s.source_files = 'objective-curl/src'
  s.public_header_files = 'objective-curl/src', 'objective-curl/include'
  s.resource  = '.empty'
  s.frameworks = 'Cocoa.Framework', 'objective-curl/dylib/libcurl.4.dylib', 'objective-curl/dylib/libssh2.1.dylib'

  # If you need to specify any other build settings, add them to the
  # xcconfig hash.
  #
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
