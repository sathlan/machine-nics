require "bundler/gem_tasks"
require "cucumber/rake/task"

Cucumber::Rake::Task.new(:run) do |task|
  task.cucumber_opts = ["features"]
end

task :default => :run

