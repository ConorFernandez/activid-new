module User::Role
  class ROLE
    USER = "user"
    EDITOR = "editor"
    ADMIN = "admin"
  end

  def user?; role == ROLE::USER; end
  def editor?; role == ROLE::EDITOR; end
  def admin?; role == ROLE::ADMIN; end
end
