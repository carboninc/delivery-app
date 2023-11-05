# frozen_string_literal: true

class PrepareDelivery
  ValidationError = Class.new StandardError

  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze

  def initialize(order, user)
    @order = order
    @user = user
    @result = DeliveryResult.new
  end

  def perform(destination_address, delivery_date)
    validate_delivery_date!(delivery_date)
    validate_destination_address!(destination_address)

    build_delivery_result(destination_address)
  rescue ValidationError => e
    handle_error(e.message)
  end

  private

  def validate_delivery_date!(delivery_date)
    raise ValidationError, 'Дата доставки уже прошла' if delivery_date < Time.current
  end

  def validate_destination_address!(destination_address)
    missing_parts = missing_address_parts(destination_address)
    return if missing_parts.empty?

    raise ValidationError,
          "Отсутствуют или неполные части адреса: #{missing_parts.join(', ')}"
  end

  def missing_address_parts(address)
    %i[city street house].reject { |part| address.send(part).present? }
  end

  def valid_address?(address)
    missing_address_parts(address).empty?
  end

  def build_delivery_result(address)
    @result.truck = find_truck(address)
    @result.weight = calculate_weight
    @result.order_number = @order.id
    @result.address = address

    @result
  end

  def calculate_weight
    @order.products.sum(&:weight)
  end

  def find_truck
    weight = calculate_weight
    TRUCKS.keys.find { |truck| TRUCKS[truck] > weight } || handle_no_truck!
  end

  def handle_no_truck!
    raise ValidationError, 'Нет машины'
  end

  def handle_error(error_message)
    @result.status = :error
    @result.error_message = error_message

    @result
  end
end

class Order
  def id
    'id'
  end

  def products
    [OpenStruct.new(weight: 20), OpenStruct.new(weight: 40)]
  end
end

class Address
  def city
    'Ростов-на-Дону'
  end

  def street
    'ул. Маршала Конюхова'
  end

  def house
    'д. 5'
  end
end

class DeliveryResult
  attr_accessor :truck, :weight, :order_number, :address, :status, :error_message

  def initialize
    @truck = nil
    @weight = nil
    @order_number = nil
    @address = nil
    @status = :ok
    @error_message = nil
  end
end

PrepareDelivery.new(Order.new, OpenStruct.new).perform(Address.new, Date.tomorrow)
