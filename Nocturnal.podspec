Pod::Spec.new do |s|
  s.name = 'Nocturnal'
  s.version = '6.0.2'
  s.summary = 'rx-based MVVM-C componets'

  s.homepage = 'https://github.com/netcosports/Nocturnal'
  s.license = { :type => "MIT" }
  s.author = {
    'Sergei Mikhan' => 'sergei@netcosports.com'
  }
  s.source = { :git => 'https://github.com/netcosports/Nocturnal.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3']

  s.source_files = 'Sources/**/*.swift'

  s.dependency 'RxSwift', '~> 6'
  s.dependency 'RxCocoa', '~> 6'
  s.dependency 'RxGesture'

  s.dependency 'Astrolabe', '~> 6'
  s.dependency 'Alidade', '~> 6'
  s.dependency 'Sundial', '~> 6'

end
