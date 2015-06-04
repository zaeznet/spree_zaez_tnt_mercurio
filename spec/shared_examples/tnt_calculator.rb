# require the helper module
require 'savon'
require 'savon/mock/spec_helper'

shared_examples_for 'tnt calculator' do

  let(:calculator) { subject.class.new }

  # include the helper module
  include Savon::SpecHelper

  # set Savon in and out of mock mode
  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  before do
    address = FactoryGirl.build(:address, zipcode: '17209420')
    # use authentication token for save the customer's CGC
    user = FactoryGirl.build(:user)
    user.authentication_token = '12345678900'
    @variant = FactoryGirl.build(:variant, weight: 1, height: 5, width: 15, depth: 20)
    @order = FactoryGirl.build(:order_with_shipments, ship_address: address, user: user)

    line_item = FactoryGirl.build(:line_item, variant: @variant, price: 100, order: @order)
    @order.line_items << line_item

    # stock location
    @stock_location = FactoryGirl.build(:stock_location, zipcode: '08465312')

    # shipment
    @shipment = FactoryGirl.build(:shipment, order: @order, stock_location: @stock_location)
    @shipment.inventory_units << FactoryGirl.build(:inventory_unit, variant: @variant, order: @order,
                                                   line_item: line_item, shipment: @shipment)

    # package
    @package = @shipment.to_package
    @package.add @shipment.inventory_units.first

    @params = {in0: {login: 'teste@email.com',
                     senha: 'password',
                     nr_identif_cliente_rem: '1234678900000',
                     nr_inscricao_estadual_remetente: '344028650118',
                     nr_identif_cliente_dest: '12345678900',
                     tp_situacao_tributaria_remetente: 'CO',
                     tp_pessoa_remetente: 'J',
                     tp_pessoa_destinatario: 'F',
                     tp_situacao_tributaria_destinatario: 'NC',
                     cep_origem: '08465312',
                     cep_destino: '17209420',
                     vl_mercadoria: '100.0',
                     ps_real: '1.0',
                     tp_servico: calculator.shipping_method,
                     tp_frete: 'C',
                     cd_divisao_cliente: 1}}

    # set the value of tnt config
    Spree::TntMercurioConfig.email          = @params[:in0][:login]
    Spree::TntMercurioConfig.password       = @params[:in0][:senha]
    Spree::TntMercurioConfig.division       = 1
    Spree::TntMercurioConfig.cgc            = @params[:in0][:nr_identif_cliente_rem]
    Spree::TntMercurioConfig.state_registry = @params[:in0][:nr_inscricao_estadual_remetente]
    Spree::TntMercurioConfig.customer_field = 'authentication_token'
  end

  after do
    # set default for preferences
    Spree::TntMercurioConfig.email          = nil
    Spree::TntMercurioConfig.password       = nil
    Spree::TntMercurioConfig.division       = nil
    Spree::TntMercurioConfig.cgc            = nil
    Spree::TntMercurioConfig.state_registry = nil
    Spree::TntMercurioConfig.type_cgc       = 'J'
    Spree::TntMercurioConfig.tax_situation  = 'CO'
    Spree::TntMercurioConfig.billet_type    = 'C'
    Spree::TntMercurioConfig.additional_value = 0
    Spree::TntMercurioConfig.additional_days  = 0
    Spree::TntMercurioConfig.customer_field   = ''
  end

  context 'compute_package' do

    it 'should calculate the price and delivery time' do

      fixture = File.read('spec/fixtures/calcula_frete/success_response.xml')

      savon.expects(:calcula_frete).with(message: @params).returns(fixture)
      response = calculator.compute_package(@package)

      expect(response).to eq(69.29)
      expect(calculator.delivery_time).to eq(3)

    end

    it 'should possible add days to delivery time' do
      Spree::TntMercurioConfig.additional_days = 5

      fixture = File.read('spec/fixtures/calcula_frete/success_response.xml')

      savon.expects(:calcula_frete).with(message: @params).returns(fixture)
      calculator.compute_package(@package)

      expect(calculator.delivery_time).to eq(8)

      # set value default after test
      Spree::TntMercurioConfig.additional_days = 0
    end

    it 'should possible add some value to price' do
      Spree::TntMercurioConfig.additional_value = 10.0

      fixture = File.read('spec/fixtures/calcula_frete/success_response.xml')

      savon.expects(:calcula_frete).with(message: @params).returns(fixture)
      response = calculator.compute_package(@package)

      expect(response).to eq(79.29)

      # set value default after test
      Spree::TntMercurioConfig.additional_value = 0
    end

  end

  context 'invalid data' do

    it 'should return false when the variant has nil/zero weight' do
      # set 0 to variant weight
      @variant.weight = 0

      fixture = File.read('spec/fixtures/calcula_frete/error_response.xml')

      savon.expects(:calcula_frete).with(message: @params).returns(fixture)
      response = calculator.compute_package(@package)

      expect(response).to be false
    end

    it 'should return false if the credentials are invalid' do
      @params[:in0][:login] = ''
      @params[:in0][:senha] = ''
      @params[:in0][:nr_identif_cliente_rem] = ''
      @params[:in0][:nr_inscricao_estadual_remetente] = ''

      Spree::TntMercurioConfig.email = ''
      Spree::TntMercurioConfig.password = ''
      Spree::TntMercurioConfig.cgc = ''
      Spree::TntMercurioConfig.state_registry = ''

      fixture = File.read('spec/fixtures/calcula_frete/invalid_credentials.xml')

      savon.expects(:calcula_frete).with(message: @params).returns(fixture)

      response = calculator.compute_package(@package)

      expect(response).to be false
    end
  end

end