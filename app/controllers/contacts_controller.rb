class ContactsController < ApplicationController

  before_action :load_contact, :except => [:new, :create, :find]

  def new
    @contact = Contact.new
    render 'edit_contact'
  end

  def create
    @contact = Contact.new(contact_params)

    new_address = parse_address
    if new_address && new_address.valid?
      assigning_new_address_object = (params[:address_specification_type] == 'existing_address')
      assign_address_to_contact(new_address, assigning_new_address_object)
      @address_list = Address.find_for_list
    end

    @saved = @contact.save
    @contact_list = Contact.find_for_list
    render 'edit_contact'
  end

  def show
    @address = @contact.address || Address.new
    is_mobile_device? ? render('show_contact') : render('edit_contact')
  end

  def update
    @contact.attributes = contact_params

    render_target = 'edit_contact'
    new_address = parse_address
    if new_address && new_address.valid? && new_address.different_from?(@contact.address)
      if changing_address_for_multiple_contacts?
        session[:changed_address] = new_address.to_json
        render_target = 'edit_contact_with_shared_address'
      else
        assigning_new_address_object = (params[:address_specification_type] == 'existing_address')
        new_address_saved = assign_address_to_contact(new_address, assigning_new_address_object)
      end
    end

    @saved = @contact.errors.blank? && @contact.save
    @address_list = Address.find_for_list if new_address_saved

    if new_address && new_address.different_from?(@contact.address)
      @address = new_address
    else
      @address = @contact.address || Address.new
    end

    render render_target
  end

  def destroy
    @old_address = Address.new
    @old_address.attributes = @contact.address.try(:attributes) || {}
    @contact.try(:destroy)
    @address_list = Address.find_for_list if @contact.address.nil?
    render 'delete_contact'
  end

  def change_address
    assigning_new_address_object = params[:submit_id] == 'no'
    changed_address_params = JSON.parse(session[:changed_address])
    changed_address = Address.find_by_id(changed_address_params['id']) || Address.new
    changed_address.attributes = changed_address_params
    new_address = assign_address_to_contact(changed_address, assigning_new_address_object)
    @contact.save

    @address = @contact.address || Address.new
    @address_list = Address.find_for_list if new_address
    render 'edit_contact'
  end

  def remove_address
    @old_address = @contact.address
    @old_address_id = @contact.remove_address
    @saved = true unless @old_address_id.nil?
    @address_list = Address.find_for_list
    render 'edit_contact'
  end

  def find
    @contact_list = Contact.where(["upper(last_name) like ?", params[:last_name].upcase << "%"]).
                            order('last_name, first_name')
    render 'find_contact'
  end

  private

  def load_contact
    @contact = Contact.find_by_id(params[:id])
  end

  def changing_address_for_multiple_contacts?
    @contact.address && @contact.address.contacts.size > 1
  end

  def assign_address_to_contact(new_address, assigning_new_address_object)
    if @contact.address.nil? || assigning_new_address_object
      @contact.assign_address(new_address)
      true
    else
      @contact.address.attributes = new_address.attributes.reject { |k,v| k == 'id' }
      false
    end
  end

  def parse_address
    if params[:address_specification_type] == 'existing_address'
      other = Contact.find_by_id(params[:other_id])
      other.address
    elsif specified_address?
      address = Address.new(address_params)
      @contact.errors.add(:base, 'Please specify a valid address') unless address.valid?
      address
    end
  end

  def specified_address?
    params[:address_specification_type] == 'specified_address' ||
            (params[:address] && params[:address][:home_phone] && !params[:address][:home_phone].blank?)
  end

  def contact_params
    params.require(:contact).permit(:prefix, :first_name, :middle_name, :last_name, :birthday, :work_phone, :cell_phone, :email, :website, :address_id)
  end

  def address_params
    params.require(:address).permit(:address1, :address2, :city, :state, :zip, :home_phone, :contact1_id, :contact2_id, :address_type_id)
  end

end
