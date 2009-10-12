require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "yandex_metrika"
    gem.summary = "[Rails] Easily enable Yandex.Metrika support in your Rails application."
    gem.description = gem.summary + "\n<br/><br/>\n" + 
                      'By default this gem will output Yandex.Metrika code for ' +
                      "every page automagically, if it's configured correctly. " +
                      "This is done by adding: <br/>\n" +
                      "Yandex::Metrika.counter_id = '123456' <br/>\n" +
                      'to your `config/environment.rb`, inserting your own COUNTER_ID. ' +
                      'This can be discovered by looking at the value of "new Ya.Metrika(123456)" ' +
                      'in the Javascript code.'

    gem.email = "zed.0xff@gmail.com"
    gem.homepage = "http://github.com/zed-0xff/yandex_metrika"
    gem.authors = ["Andrey 'Zed' Zaikin"]
    gem.rubyforge_project = 'yandex-metrika'
    #gem.add_development_dependency "thoughtbot-shoulda"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.add_dependency 'actionpack', '>= 2.3.3'
    gem.add_dependency 'activesupport', '>= 2.3.3'
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "yandex_metrika #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
