require "clockwork"
require "platform-api"

module Clockwork
  handler do |job|
    # run the command in a detached Heroku process
    heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"])
    heroku.dyno.create(ENV["HEROKU_APP_NAME"], {command: job})
  end

  every(1.minute,  "rake encoding:check_user_uploads")
  every(5.minutes, "rake encoding:check_cuts")
end
