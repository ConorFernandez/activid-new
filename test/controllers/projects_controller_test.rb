require "test_helper"

class ProjectsControllerTest < ActionController::TestCase
  def setup
    @mock_stripe_customer = OpenStruct.new(id: "customer_id_asdf", cards: [OpenStruct.new(id: "card_id_asdf")])
  end

  test "POST create redirects to step 2" do
    data = {
      name: "My Project",
      category: Project::CATEGORIES.keys.first,
      desired_length: Project::LENGTHS.keys.first,
      instructions: "None"
    }

    post :create, step: 1, project: data

    project = Project.last

    assert_redirected_to project_step2_path(project)
  end

  test "POST create assigns project to current_user" do
    user = users(:joey)
    sign_in user

    data = {
      name: "My Project",
      category: Project::CATEGORIES.keys.first,
      desired_length: Project::LENGTHS.keys.first,
      instructions: "None"
    }

    post :create, step: 1, project: data

    project = Project.last

    assert_equal user, project.user
  end

  test "PUT update attaches file upload objects" do
    project = projects(:no_files)
    files = [file_uploads(:three), file_uploads(:four)]

    assert_equal 0, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update removes files not included in payload" do
    project = projects(:has_files)
    sign_in project.user
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: []

    assert_equal 0, project.file_uploads.count
  end

  test "PUT update removes all files if param is missing" do
    project = projects(:has_files)
    sign_in project.user
    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2

    assert_equal 0, project.file_uploads.count
  end

  test "PUT update step 2 does not affect music files" do
    project = projects(:has_music_and_videos)
    sign_in project.user
    assert_equal 1, project.music_uploads.count
    assert_equal 1, project.video_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: ([file_uploads(:four)] + project.video_uploads).map(&:uuid)
    project.reload

    assert_equal 1, project.music_uploads.count
    assert_equal 2, project.video_uploads.count
  end

  test "PUT update step 3 does not affect video files" do
    project = projects(:has_music_and_videos)
    sign_in project.user
    assert_equal 1, project.music_uploads.count
    assert_equal 1, project.video_uploads.count

    put :update, id: project.uuid, step: 3, file_upload_uuids: ([file_uploads(:song2)] + project.music_uploads).map(&:uuid)
    project.reload

    assert_equal 2, project.music_uploads.count
    assert_equal 1, project.video_uploads.count
  end

  test "PUT update re-uses existing files" do
    project = projects(:has_files)
    sign_in project.user
    files = project.file_uploads + [file_uploads(:three)]

    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 3, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update re-uses existing while also deleting some uploads" do
    project = projects(:has_files)
    sign_in project.user
    files = [file_uploads(:one), file_uploads(:three)]

    assert_equal 2, project.file_uploads.count

    put :update, id: project.uuid, step: 2, file_upload_uuids: files.map(&:uuid)

    assert_equal 2, project.file_uploads.count
    assert_equal files.map(&:id).sort, project.reload.file_uploads.map(&:id).sort
  end

  test "PUT update attaches activid music options to a project" do
    project = projects(:has_files)
    sign_in project.user
    urls = ["http://foo.com/one.mp3", "http://foo.com/two.mp3"]

    put :update, id: project.uuid, step: 3, activid_music_urls: urls

    assert_equal project.reload.activid_music_urls.sort, urls.sort
  end

  test "PUT update associates current_user with project if project has none" do
    project = projects(:has_files_no_owner)
    sign_in users(:joey)

    assert_equal nil, project.user

    put :update, id: project.uuid, step: 4

    assert_equal users(:joey), project.reload.user
  end

  test "PUT update creates and stores a stripe customer token if none exists" do
    project = projects(:has_files)
    sign_in project.user
    stripe_customer_id = "customer_id_asdf"
    stripe_card_id = "card_id_asdf"

    Stripe::Customer.expects(:create).returns(OpenStruct.new(id: stripe_customer_id, cards: [OpenStruct.new(id: stripe_card_id)]))

    put :update, id: project.uuid, step: 4, stripe_token: "asdf"

    project.reload

    assert_equal stripe_customer_id, project.user.stripe_customer_id
    assert_equal stripe_card_id, project.stripe_card_id
  end

  test "PUT update adds a card to a user if stripe customer already exists" do
    project = projects(:has_files)
    user = project.user
    sign_in user

    mock_cards = OpenStruct.new
    mock_customer = OpenStruct.new(cards: mock_cards)
    user.update(stripe_customer_id: "asdf")
    Stripe::Customer.expects(:retrieve).returns(mock_customer)
    mock_cards.expects(:create).returns(OpenStruct.new(id: "new_card_id"))

    put :update, id: project.uuid, step: 4, stripe_token: "asdf"

    assert_equal "new_card_id", project.reload.stripe_card_id
    assert_equal "asdf", project.user.stripe_customer_id
  end

  test "PUT update uses an existing card if one is provided" do
    project = projects(:has_files)
    user = project.user
    sign_in user

    mock_cards = OpenStruct.new
    mock_customer = OpenStruct.new(cards: mock_cards)
    user.update(stripe_customer_id: "asdf")
    Stripe::Customer.expects(:retrieve).returns(mock_customer)
    mock_cards.expects(:retrieve).returns(OpenStruct.new(id: "existing_card_id"))

    put :update, id: project.uuid, step: 4, stripe_card_id: "existing_card_id"

    assert_equal "existing_card_id", project.reload.stripe_card_id
    assert_equal "asdf", project.user.stripe_customer_id
  end

  test "checkout caches price on project and updates status" do
    Stripe::Customer.expects(:create).returns(@mock_stripe_customer)

    sign_in users(:joey)
    project = projects(:has_files)

    assert_equal nil, project.price

    put :update, id: project.uuid, step: 4, stripe_token: "asdf"

    project.reload

    assert project.available?
    assert_not_equal nil, project.price
  end

  test "checkout sets submitted_at" do
    Stripe::Customer.expects(:create).returns(@mock_stripe_customer)

    sign_in users(:joey)
    project = projects(:has_files)

    assert_equal nil, project.submitted_at

    put :update, id: project.uuid, step: 4, stripe_token: "asdf"

    project.reload

    assert_not_equal nil, project.submitted_at
  end
end
