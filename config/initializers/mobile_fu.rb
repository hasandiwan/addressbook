require Rails.root + 'lib/mobile-fu/lib/mobile_fu_helper.rb'
require Rails.root + 'lib/mobile-fu/lib/mobilized_styles'
require Rails.root + 'lib/mobile-fu/lib/mobile_fu'

ActionView::Base.send(:include, MobileFuHelper)
ActionView::Base.send(:include, MobilizedStyles)
module MobilizationMethod
  def stylesheet_link_tag
    return mobilization(:params)
  end
end
