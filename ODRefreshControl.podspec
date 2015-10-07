Pod::Spec.new do |s|
  s.name     = 'ODRefreshControl'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.summary  = "水滴型下拉刷新控件(A pull down to refresh control like water dropped)."
  s.homepage = 'https://github.com/wolfcon/ODRefreshControl'
  s.author   = { 'Frank(fork from Fabio Ritrovato)' => '472730949@qq.com' }
  s.source   = { :git => 'https://github.com/wolfcon/ODRefreshControl.git', :tag => '0.1' }

  s.description = '水滴型下拉刷新控件(A pull down to refresh control like water dropped).'
  s.platform    = :ios

  s.source_files = 'ODRefreshControl/ODRefreshControl*.{h,m}'
  #s.clean_path   = 'Demo'
  s.framework    = 'QuartzCore'

  s.requires_arc = true
end
