#
#  Rakefile
#
#  Created by Benoit Sarrazin on Jan 26, 2016.
#  Copyright (c) 2016 Berzerker IO. All rights reserved.
#

require 'colorize'

desc "The default task."
task :default => [:bundle_reset, :pod_reset]

desc "Removes the 'Gemfile.lock' file."
task :bundle_lock_clean do
    puts "Removing the 'Gemfile.lock' file.".colorize(:red)
    sh "rm -rf Gemfile.lock"
end

desc "Run 'bundle install' in the current directory."
task :bundle_install do
  puts "Running 'bundle install'".colorize(:green)
  sh "bundle install"
end

desc "Completely resets the 'bundler' environment."
task :bundle_reset => [:bundle_lock_clean, :bundle_install]

desc "Removes the 'pods' folder."
task :pod_clean do
  puts "Removing the 'Pods/' folder.".colorize(:red)
  sh "rm -rf Pods"
end

desc "Removes the 'Podfile.lock' file."
task :pod_lock_clean do
  puts "Removing the 'Podfile.lock' file.".colorize(:red)
  sh "rm -rf Podfile.lock"
end

desc "Run 'pod install' in the current directory."
task :pod_install do
  puts "Running 'pod install'".colorize(:green)
  sh "pod install"
end

desc "Runs 'pod update' in the current directory."
task :pod_update do
  puts "Running 'pod update'".colorize(:green)
  sh "pod update"
end

desc "Completely resets the 'pod' environment."
task :pod_reset => [:pod_clean, :pod_lock_clean, :pod_install]

desc "Bumps the build number."
task :bump do
    puts "Bumping the version number."
    sh "agvtool bump -all"
end
