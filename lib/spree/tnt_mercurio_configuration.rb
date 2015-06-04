class Spree::TntMercurioConfiguration < Spree::Preferences::Configuration

  preference :email,    :string   # email
  preference :password, :string   # senha
  preference :division, :integer  # codigo da divisao

  preference :type_cgc,       :string, default: 'J'   # pessoa fisica (F) ou juridica (J)
  preference :cgc,            :string                 # cpf ou cnpj do remetente
  preference :state_registry, :string                 # inscricao estadual
  preference :tax_situation,  :string, default: 'CO'  # situacao tributaria
  preference :billet_type,    :string, default: 'C'   # tipo de cobranca (CIF ou FOB)

  preference :customer_field, :string  # campo que esta armazenado o CPF/CNPJ do cliente

  preference :additional_days,  :integer, default: 0
  preference :additional_value, :integer, default: 0

end