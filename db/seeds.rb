user = User.create!(
  email: "joey@polymathic.me",
  full_name: "joey user",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "user"
)

editor = User.create!(
  email: "joey-editor@polymathic.me",
  full_name: "joey editor",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "editor"
)

admin = User.create!(
  email: "joey-admin@polymathic.me",
  full_name: "joey admin",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "admin"
)

projects = [1,2,3,4].map do |i|
  user.projects.create!(
    name: "My Project #{i}",
    category: "vacation",
    desired_length: "five_ten",
    turnaround: "seven_day"
  )
end

projects.each do |p|
  p.file_uploads.create!(
    url: "http://activid.s3.aws.com/file1.mov"
  )

  p.file_uploads.create!(
    url: "http://activid.s3.aws.com/file2.mov"
  )
end

projects.first.submit!
