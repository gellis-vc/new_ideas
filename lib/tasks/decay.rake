namespace :ideax do
    desc 'Bulk update all time-base decay fields in DB'
    task :decay => :environment do
      Decayer.run_all(
        :half_life => {
          :idea_rating => 60.days,
          :user_contribution_points => 40.days
        }
      )
    end
end

