require "test_helper"

class CommentsControllerTest < ActionController::TestCase
  test "user can create a comment for one of their projects" do
    project = projects(:has_files)
    sign_in project.user

    comments_count = project.comments.count
    body = "This is my comment"

    post :create, comment: {commentable_uuid: project.uuid, commentable_type: "Project", body: body}

    assert_equal comments_count + 1, project.reload.comments.count
    assert_equal body, project.comments.last.body
    assert_redirected_to project_path(project, anchor: "comment_#{project.comments.last.id}")
  end

  test "user cannot create a comment for a project that doesn't belong to them" do
    project = projects(:has_files)
    sign_in users(:wilson)

    assert_raises ActiveRecord::RecordNotFound do
      post :create, comment: {commentable_uuid: project.uuid, commentable_type: "Project", body: "_"}
    end
  end

  test "editors can create a comment for a project they're assigned to" do
    project = projects(:assigned)
    sign_in project.editor

    comments_count = project.comments.count
    body = "This is my comment"

    post :create, comment: {commentable_uuid: project.uuid, commentable_type: "Project", body: body}

    assert_equal comments_count + 1, project.reload.comments.count
    assert_equal body, project.comments.last.body
    assert_redirected_to project_path(project, anchor: "comment_#{project.comments.last.id}")
  end

  test "editors cannot create a comment for a project they're not assigned to" do
    project = projects(:assigned)
    sign_in users(:editor2)

    assert_raises ActiveRecord::RecordNotFound do
      post :create, comment: {commentable_uuid: project.uuid, commentable_type: "Project", body: "_"}
    end
  end

  test "admins can comment on a project" do
    project = projects(:has_files)
    sign_in users(:admin)

    comments_count = project.comments.count
    body = "This is my comment"

    post :create, comment: {commentable_uuid: project.uuid, commentable_type: "Project", body: body}

    assert_equal comments_count + 1, project.reload.comments.count
    assert_equal body, project.comments.last.body
    assert_redirected_to project_path(project, anchor: "comment_#{project.comments.last.id}")
  end

  test "admins can comment on an editor" do
    editor = users(:editor1)
    admin = users(:admin)

    sign_in admin
    comments_count = editor.comments.count
    body = "This is my comment"

    post :create, comment: {commentable_id: editor.id, commentable_type: "User", body: body}

    assert_equal comments_count + 1, editor.reload.comments.count
    assert_equal body, editor.comments.last.body
    assert_redirected_to editor_path(editor)
  end

  test "editors can comment on themselves" do
    editor = users(:editor1)
    admin = users(:admin)

    sign_in editor
    comments_count = editor.comments.count
    body = "This is my comment"

    post :create, comment: {commentable_id: editor.id, commentable_type: "User", body: body}

    assert_equal comments_count + 1, editor.reload.comments.count
    assert_equal body, editor.comments.last.body
    assert_redirected_to editor_path(editor)
  end

  test "editors can't comment on other editors" do
    editor = users(:editor1)
    admin = users(:admin)

    sign_in users(:editor2)

    assert_raises ActiveRecord::RecordNotFound do
      post :create, comment: {commentable_id: editor.id, commentable_type: "User", body: "_"}
    end
  end
end
