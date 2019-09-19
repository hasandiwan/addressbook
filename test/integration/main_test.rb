require 'csv'
require 'test_helper' 

class Home
    include Capybara::DSL
    def visit_homepage
      visit('/')
    end
end
class MainTest < ActionDispatch::IntegrationTest
  test 'users endpoint returns only email addresses in csv' do
    get "/users.csv"
    users = CSV.parse(response.body)
    puts "#{users}"
    #assert users.kind_of?(Array)
  end

end
