module Spree
  class Calculator::Shipping::TntMercurioANC < Calculator::Shipping::TntMercurioBaseCalculator

    def self.description
      'TNT Mercúrio - Aéreo Nacional'
    end

    def shipping_method
      'ANC'
    end

  end
end
