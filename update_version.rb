#!/usr/bin/ruby

# This script should be run from XCode.
# The script copies CFBundleShortVersionString and CFBundleVersion (build number) in the project's Info.plist file to the Settings.bundle Root.plist file. 


# Fail if not run from Xcode
raise "Must be run from Xcode's Run Script Build Phase" unless ENV['XCODE_VERSION_ACTUAL']

plist_file = "#{ENV['BUILT_PRODUCTS_DIR']}/#{ENV['INFOPLIST_PATH']}"
# Convert the binary plist to xml based
`/usr/bin/plutil -convert xml1 #{plist_file}`

# Open Info.plist and get the line after the CFBundleShortVersionString, which contains our version number,
# read that line and pull out the value from the XML string
target_line = nil
File.open(plist_file, 'r').each_with_index { |line, line_number| target_line = line_number + 1 if line =~/<key>CFBundleShortVersionString<\/key>/ }
raise "No version number found" if target_line == nil
version = IO.readlines(plist_file)[target_line].scan(/<string>(.*?)<\/string>/)

File.open(plist_file, 'r').each_with_index { |line, line_number| target_line = line_number + 1 if line =~/<key>CFBundleVersion<\/key>/ }
raise "No version number found" if target_line == nil
build = IO.readlines(plist_file)[target_line].scan(/<string>(.*?)<\/string>/)


# Convert back to binary plist
`/usr/bin/plutil -convert binary1 #{plist_file}`


# Copy the version and build number to the settings plist file
settings_plist = "#{ENV['BUILT_PRODUCTS_DIR']}/#{ENV['EXECUTABLE_FOLDER_PATH']}/Settings.bundle/Root.plist"
`/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:1:DefaultValue #{version} (#{build})" #{settings_plist}`

