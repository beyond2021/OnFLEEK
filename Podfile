platform :ios, "8.0"
use_frameworks!


target 'OnFLEEK' do
pod "Koloda"
end

target 'OnFLEEKTests' do

end

target 'OnFLEEKUITests' do

end
post_install do |installer|
`find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end