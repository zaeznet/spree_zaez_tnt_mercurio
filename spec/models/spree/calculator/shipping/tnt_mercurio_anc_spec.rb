require 'spec_helper'
require 'shared_examples/tnt_calculator'

describe Spree::Calculator::Shipping::TntMercurioANC do
  before do
    @anc = Spree::Calculator::Shipping::TntMercurioANC.new
  end

  it_behaves_like 'tnt calculator'

  it 'should have a description' do
    expect(@anc.description).to eq('TNT Mercúrio - Aéreo Nacional')
  end

  it 'should have a shipping method' do
    expect(@anc.shipping_method).to eq('ANC')
  end

end
