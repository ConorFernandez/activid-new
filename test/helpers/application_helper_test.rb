require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "duration works for sub-hour durations" do
    assert_equal "0:01", duration(1)
    assert_equal "1:40", duration(100)
    assert_equal "10:40", duration(640)
  end

  test "duration works for > 1 hour durations" do
    assert_equal "1:00:01", duration(3601)
    assert_equal "10:01:40", duration(36100)
  end
end
