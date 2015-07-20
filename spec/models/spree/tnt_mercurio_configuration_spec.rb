require 'spec_helper'

describe Spree::TntMercurioConfiguration do
  before do
    @object = Spree::TntMercurioConfiguration.new
  end

  [:email, :password, :division, :cgc, :type_cgc, :state_registry, :tax_situation,
   :billet_type, :additional_days, :additional_value, :customer_field].each do |preference|
    it "should has #{preference} preference" do
      expect(@object.has_preference?(preference)).to be true
    end
  end
end