User.create!(
  email: "joey@polymathic.me",
  full_name: "joey user",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "user"
)

User.create!(
  email: "joey-editor@polymathic.me",
  full_name: "joey editor",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "editor"
)

User.create!(
  email: "joey-admin@polymathic.me",
  full_name: "joey admin",
  password: "asdfasdf",
  password_confirmation: "asdfasdf",
  role: "admin"
)
