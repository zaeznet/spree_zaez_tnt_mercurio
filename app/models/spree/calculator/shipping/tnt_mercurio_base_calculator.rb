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
      try_calculate_from_orders(zipcode_to, object.weight)
    end

    # Tenta buscar um pedido feito para o mesmo CEP de entrega e
    # que tenha um peso parecido (diferenca de 1kg para mais ou menos)
    # para recuperar o valor do frete e o tempo de entrega
    def try_calculate_from_orders(zipcode, weight)
      shipping_type = "Spree::Calculator::Shipping::TntMercurio#{shipping_method}"
      calculator = Spree::Calculator.find_by(type: shipping_type, calculable_type: 'Spree::ShippingMethod')
      return {} if calculator.nil?
      shipping_method_id = calculator.calculable_id

      shipping_rates_id = Spree::ShippingRate.joins(:shipping_method).joins(shipment: :order).
          joins('INNER JOIN spree_addresses ON spree_addresses.id = spree_orders.ship_address_id').
          where(shipping_method_id: shipping_method_id, spree_addresses: { zipcode: zipcode }).
          group('spree_shipping_rates.id').pluck(:id)

      init_value = weight - 1
      final_value = weight + 1

      shipping_rates_id.each do |id|
        shipping_rate = Spree::ShippingRate.find(id)
        weight = shipping_rate.shipment.to_package.weight

        if weight.between?(init_value, final_value)
          return { cost: shipping_rate.cost.to_f, delivery_time: shipping_rate.delivery_time }
        end
      end
      {}
    rescue
      {}
    end

  end
end