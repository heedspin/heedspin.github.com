# Rakefile
require 'rake'
 
# tasks/site.rake
namespace :site do
  desc "Build css files from .less files"
  task :less do
    less_directory = '_less'
    css_directory = 'css'
    Dir.glob(less_directory + '/*.less').each do |file|
      if File.file?(file)
        file_name = file.split('/').last.split('.').first
        puts "* Creating css file for less file named #{file_name} \n"
        `lessc #{less_directory}/#{file_name}.less #{css_directory}/#{file_name}.css`
      end
    end
  end
  
  desc "Build static files from jekyll files"
  task :jekyll do
    puts "* Building static files from jekyll files"
    `jekyll build`
  end
  
  desc "Build site (less and jekyll)"
  task :build do
    puts "[START] Building site [START]"
    Rake::Task["site:less"].invoke
    Rake::Task["site:jekyll"].invoke
    puts "[END] Building site [END]"
  end
end

task :default => 'site:build'
