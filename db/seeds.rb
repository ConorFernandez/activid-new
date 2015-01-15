user = User.create!(
  email: "user@gmail.com",
  full_name: "user user",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "user"
)

editor = User.create!(
  email: "editor@gmail.com",
  full_name: "editor editor",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "editor"
)

admin = User.create!(
  email: "admin@gmail.com",
  full_name: "admin admin",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "admin"
)
