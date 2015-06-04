module SpreeTntMercurio
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_zaez_tnt_mercurio'

    initializer 'spree.tnt_zaez_mercurio.preferences', :before => :load_config_initializers do |app|
      # require file with the preferences of the TNT Mercurio
      require 'spree/tnt_mercurio_configuration'
      Spree::TntMercurioConfig = Spree::TntMercurioConfiguration.new
      #
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer 'spree_zaez_tnt_mercurio.register.calculators' do |app|
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::TntMercurioRNC
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::TntMercurioANC
    end

    config.to_prepare &method(:activate).to_proc
  end
end