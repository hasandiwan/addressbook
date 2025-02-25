class MainController < ApplicationController
  before_action :authenticate_user!, :except => :users

  def index
    @group_list = Group.find_for_list
    @contact_list = Contact.find_for_list
    @address_list = Address.find_for_list
  end

  def users
    @user = User.pluck(:email)
    ret = "\n"
    @user.each { |u| ret = "#{ret}\n#{u}" }
    @user
  end
end
