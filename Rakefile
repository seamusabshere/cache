require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

# http://stackoverflow.com/questions/2138427/can-i-get-my-readme-textile-into-my-rdoc-with-proper-formatting
desc "Generate RDoc"
task :rdoc => ['doc:generate']
namespace :doc do
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'rdoc')
  files = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + [ File.join(project_root, 'README.md') ]
  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   = files
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.md']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_dir if File.exists?(doc_destination)
  end

end
