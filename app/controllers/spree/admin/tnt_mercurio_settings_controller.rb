class Spree::Admin::TntMercurioSettingsController < Spree::Admin::BaseController

  def edit
    @tax_situations = [:co, :nc, :ci, :cm, :cn, :me, :mn, :pr, :pn, :op, :on, :of]
    @user_attr = Spree::User.new.attribute_names
    @config = Spree::TntMercurioConfiguration.new
  end

  def update
    config = Spree::TntMercurioConfiguration.new

    params.each do |name, value|
      next unless config.has_preference? name
      config[name] = value
    end
    flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:tnt_mercurio_settings))
    redirect_to edit_admin_tnt_mercurio_settings_path
  end

end