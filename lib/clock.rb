require "clockwork"
require "platform-api"

module Clockwork
  handler do |job|
    if ENV["HEROKU_API_KEY"] && ENV["HEROKU_APP_NAME"]
      # run the command in a detached Heroku process
      heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"])
      heroku.dyno.create(ENV["HEROKU_APP_NAME"], {command: job})
    else
      puts "Cannot run job \"#{job}\" - HEROKU_API_KEY or HEROKU_APP_NAME not present."
    end
  end

  every(1.minute,  "rake encoding:check_user_uploads")
  every(5.minutes, "rake encoding:check_cuts")
  every(1.day,     "rake pay_editors", at: "04:00")
end
