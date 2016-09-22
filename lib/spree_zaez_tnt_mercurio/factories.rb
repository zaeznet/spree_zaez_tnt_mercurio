FactoryGirl.define do

  factory :order_with_shipments, class: Spree::Order do
    user
    store
    ship_address
  end

  factory :shipping_rate, class: Spree::ShippingRate do
    selected 1
    cost 10
    delivery_time 3
    association :shipping_method, factory: :shipping_method
    association :shipment, factory: :shipment
  end

end
