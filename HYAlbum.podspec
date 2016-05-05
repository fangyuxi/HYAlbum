Pod::Spec.new do |s|
  s.name             = "HYAlbum"
  s.version          = "0.1"
  s.summary          = "A Photo Libary For HYAlbum"
  s.description      = "A Photo Libary"

  s.homepage         = "https://github.com/fangyuxi/HYAlbum"
  s.license          = 'MIT'
  s.author           = { "fangyuxi" => "xcoder.fang@gmail.com" }
  s.source           = { :git => "https://github.com/fangyuxi/HYAlbum.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'Pod/Classes/**/*'
  s.resources = 'Pod/Resources/*.{bundle}'

end
