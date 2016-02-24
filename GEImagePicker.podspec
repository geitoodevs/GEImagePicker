#
# Be sure to run `pod lib lint GEImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GEImagePicker"
  s.version          = "0.1.0"
  s.summary          = "Easy image picker for Swift"
  s.description      = "Easy image picker - Closure callback with status - Permission Check - Action Sheet tool"

  s.homepage         = "https://github.com/miguelappsonline/GEImagePicker"
  s.license          = 'MIT'
  s.author           = { "Miguel Developer" => "miguel@appsonline.es" }
  s.source           = { :git => "https://github.com/miguelappsonline/GEImagePicker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/geitoodevs'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GEImagePicker' => ['Pod/Assets/*.png']
  }
end
