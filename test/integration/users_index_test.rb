require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @inactive = users(:volcano)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # Activation test and refactoring: Exercise 3
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "index should not contain inactive accounts" do
    log_in_as(@admin)
    get users_path
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # Activation test and refactoring: Exercise 3
      unless user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name, count: 0
      end
    end
  end

  # Not sure if it's a good place for this test
  test "inactive users page should redirect to root" do
    log_in_as(@non_admin)
    get user_path(@inactive)
    assert_redirected_to root_url
  end

end
