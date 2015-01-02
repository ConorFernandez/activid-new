ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  server: "email.us-west-2.amazonaws.com",
  access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
