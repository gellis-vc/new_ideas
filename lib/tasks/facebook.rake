namespace "facebook" do
  desc "Start a reverse tunnel from FACEBOOK_CONFIG['host'] to localhost"
  task "tunnel" => "environment" do
    puts "Tunneling #{FACEBOOK_CONFIG['host']}:#{FACEBOOK_CONFIG['port']} to 0.0.0.0:3000"
    command = "ssh #{FACEBOOK_CONFIG['ssh_params']} #{FACEBOOK_CONFIG['host']} -nNT -g -R *:#{FACEBOOK_CONFIG['port']}:0.0.0.0:3000"
    puts "Tunnel command is: #{command}"
    `#{command}`
  end

  desc "Check if reverse tunnel is running"
  task "status" => "environment" do
    if `ssh #{FACEBOOK_CONFIG['ssh_params']} #{FACEBOOK_CONFIG['host']} netstat -an | 
        egrep "tcp.*:#{FACEBOOK_CONFIG['port']}.*LISTEN" | wc`.to_i > 0
      puts "Facebook tunnel seems ok"
    else
      puts "Facebook tunnel appears down"
    end
  end
  
  desc "Refresh facebook templates"
  task "refresh_templates" => "environment" do
    puts "Cleaning up any old templates ..."
    Facebooker::Rails::Publisher::FacebookTemplate.destroy_all
    
    puts "Registering templates"
    IdeaPublisher.register_all_templates
    puts "\nFinished registering all templates."
  end
end