module Spree
  class Calculator::Shipping::TntMercurioRNC < Calculator::Shipping::TntMercurioBaseCalculator

    def self.description
      'TNT Mercúrio - Rodoviário Nacional'
    end

    def shipping_method
      'RNC'
    end

  end
end
