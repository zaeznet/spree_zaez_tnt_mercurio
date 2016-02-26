module Spree
  class Calculator::Shipping::TntMercurioBaseCalculator < Spree::ShippingCalculator

    attr_reader :delivery_time

    def compute_package(object)
      return if object.nil?
      order = if object.is_a?(Spree::Order) then object else object.order end

      stock_location = object.stock_location

      cgc_customer = order.user.attributes[Spree::TntMercurioConfig.customer_field]
      cgc_type = if cgc_customer.delete('.').delete('-').size <= 11 then 'F' else 'J' end

      zipcode_from = stock_location.zipcode.gsub(/[.-]/i, '')
      zipcode_to = order.ship_address.zipcode.gsub(/[.-]/i, '')

      params = {in0: {login: Spree::TntMercurioConfig.email,
                      senha: Spree::TntMercurioConfig.password,
                      nr_identif_cliente_rem: Spree::TntMercurioConfig.cgc,
                      nr_inscricao_estadual_remetente: Spree::TntMercurioConfig.state_registry,
                      nr_identif_cliente_dest: cgc_customer,
                      tp_situacao_tributaria_remetente: Spree::TntMercurioConfig.tax_situation,
                      tp_pessoa_remetente: Spree::TntMercurioConfig.type_cgc,
                      tp_pessoa_destinatario: cgc_type,
                      tp_situacao_tributaria_destinatario: 'NC',
                      cep_origem: zipcode_from,
                      cep_destino: zipcode_to,
                      vl_mercadoria: order.amount.to_s,
                      ps_real: object.weight.to_s,
                      tp_servico: shipping_method,
                      tp_frete: Spree::TntMercurioConfig.billet_type,
                      cd_divisao_cliente: Spree::TntMercurioConfig.division}}

      client = Savon.client(wsdl: 'http://ws.tntbrasil.com.br/servicos/CalculoFrete?wsdl')
      response = client.call(:calcula_frete, message: params).body

      @delivery_time = response[:calcula_frete_response][:out][:prazo_entrega].to_i + Spree::TntMercurioConfig.additional_days

      cost = response[:calcula_frete_response][:out][:vl_total_frete].to_f + Spree::TntMercurioConfig.additional_value
      {cost: cost, delivery_time: @delivery_time}
    rescue
      {}
    end
  end
end