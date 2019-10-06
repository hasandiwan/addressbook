require 'csv'
require 'test_helper' 

class MainTest < ApplicationSystemTestCase
  test "Visit homepage" do
    visit '/'
    assert(page.html.index('Address Book').nil? == false)
  end

  test 'users endpoint returns only email addresses in csv' do
    get "/users.csv"
    users = CSV.parse(response.body)
    assert(users.kind_of?(Array))
  end

end
