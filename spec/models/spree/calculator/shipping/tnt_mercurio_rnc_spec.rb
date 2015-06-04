require 'spec_helper'

describe Spree::Calculator::Shipping::TntMercurioRNC do
  before do
    @rnc = Spree::Calculator::Shipping::TntMercurioRNC.new
  end

  it_behaves_like 'tnt calculator'

  it 'should have a description' do
    expect(@rnc.description).to eq('TNT Mercúrio - Rodoviário Nacional')
  end

  it 'should have a shipping method' do
    expect(@rnc.shipping_method).to eq('RNC')
  end

end
