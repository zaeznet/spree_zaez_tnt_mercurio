require 'spec_helper'

describe 'TNT Settings', type: :feature do

  before do
    @admin = Spree.user_class.create(email: 'admin@admin.com', password: 'password', password_confirmation: 'password')
    @role = Spree::Role.create(name: 'admin')
    @role.users << @admin
    sign_in_admin! @admin
  end

  context 'visit TNT settings' do
    it 'should be a link to tnt settings' do
      within('.sidebar') { page.find_link('TNT Mercurio Settings')['/admin/tnt_mercurio_settings/edit'] }
    end
  end

  context 'show TNT settings', js: true do
    it 'should be present all tnt settings' do
      visit spree.edit_admin_tnt_mercurio_settings_path

      expect(page).to have_selector '#email'
      expect(page).to have_selector '#password'
      expect(page).to have_selector '#division'
      expect(page).to have_selector '#cgc'
      expect(page).to have_selector '#state_registry'
      expect(page).to have_selector '[name=type_cgc]'
      expect(page).to have_selector '[name=billet_type]'
      expect(page).to have_selector '[name=tax_situation]'
      expect(page).to have_selector '#additional_days'
      expect(page).to have_selector '#additional_value'
      expect(page).to have_selector '#customer_field'
    end
  end

  context 'edit TNT settings' do
    before { visit spree.edit_admin_tnt_mercurio_settings_path }

    it 'can edit the email', js: true do
      fill_in 'Email', with: 'some@email.com'
      click_button 'Update'

      verify_tnt_input_value 'email', Spree::TntMercurioConfig, 'some@email.com', ''
    end

    it 'can edit the password', js: true do
      fill_in 'Password', with: '123'
      click_button 'Update'
      verify_tnt_input_value 'password', Spree::TntMercurioConfig, '123', ''
    end

    it 'can edit the division', js: true do
      fill_in 'Division', with: '1'
      click_button 'Update'
      verify_tnt_input_value 'division', Spree::TntMercurioConfig, 1, 0
    end

    it 'can edit the CGC', js: true do
      fill_in 'CGC', with: '12345'
      click_button 'Update'
      verify_tnt_input_value 'cgc', Spree::TntMercurioConfig, '12345', ''
    end

    it 'can edit the state registry', js: true do
      fill_in 'State Registry', with: '123'
      click_button 'Update'
      verify_tnt_input_value 'state_registry', Spree::TntMercurioConfig, '123', ''
    end

    it 'can edit the CGC type', js: true do
      find(:css, '#type_cgc_F').set true
      click_button 'Update'

      expect(Spree::TntMercurioConfig.type_cgc).to eq 'F'
      expect(find_field('type_cgc_F')).to be_checked

      # set default
      Spree::TntMercurioConfig.type_cgc = 'J'
    end

    it 'can edit the billet type', js: true do
      find(:css, '#billet_type_F').set true
      click_button 'Update'

      expect(Spree::TntMercurioConfig.billet_type).to eq 'F'
      expect(find_field('billet_type_F')).to be_checked

      # set default
      Spree::TntMercurioConfig.billet_type = 'C'
    end

    it 'can edit the tax situation', js: true do
      find(:css, '#tax_situation_ME').set true
      click_button 'Update'

      expect(Spree::TntMercurioConfig.tax_situation).to eq 'ME'
      expect(find_field('tax_situation_ME')).to be_checked

      # set default
      Spree::TntMercurioConfig.tax_situation = 'CO'
    end

    it 'can edit the additional days', js: true do
      fill_in 'Additional Days', with: '3'
      click_button 'Update'
      verify_tnt_input_value 'additional_days', Spree::TntMercurioConfig, 3, 0
    end

    it 'can edit the additional value', js: true do
      fill_in 'Additional Value', with: '10'
      click_button 'Update'
      verify_tnt_input_value 'additional_value', Spree::TntMercurioConfig, 10, 0
    end

    it 'can edit the customer field', js: true do
      select('Email', :from => 'Customer Field')
      click_button 'Update'
      verify_tnt_input_value 'customer_field', Spree::TntMercurioConfig, 'email', ''
    end
  end
end