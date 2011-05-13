namespace :deploy do
  task :mango do 
    deploy('mango')
  end
  task :production do 
    deploy('ideax')
  end

  task :reset do
    puts "clearing staging git repo."
    FileUtils.rm_f('.git')
  end
end
private
def deploy(host)
  unless File.exists?('.git')
    sh "git init"
  end
  puts "pushing to local git repo.."
  puts sh "git add ."
  puts sh "git commit -m \"Deploy to heroku\""
  puts "pushing to heroku..."
  puts sh "git push -f git@heroku.com:#{host}.git"
  puts "done."
end
