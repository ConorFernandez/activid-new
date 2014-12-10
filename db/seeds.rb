user = User.create!(
  email: "user@gmail.com",
  full_name: "joey user",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "user"
)

editor = User.create!(
  email: "editor@gmail.com",
  full_name: "joey editor",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "editor"
)

admin = User.create!(
  email: "admin@gmail.com",
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
    url: "//activid-dev.s3.amazonaws.com/seeds/wrecking_ball.mp4"
  )

  p.file_uploads.create!(
    url: "//activid-dev.s3.amazonaws.com/seeds/dog_the_shot.mp4"
  )
end

projects.first.submit!
