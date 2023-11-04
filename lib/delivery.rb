# frozen_string_literal: true

class PrepareDelivery
  TRUCKS = { kamaz: 3000, gazel: 1000 }.freeze

  def initialize(order, user)
    @order = order
    @user = user
    @result = { truck: nil, weight: nil, order_number: @order.id, address: nil, status: :ok }
  end

  def perform(destination_address, delivery_date)
    validate_delivery_date!(delivery_date)
    validate_destination_address!(destination_address)

    @result[:truck] = find_truck
    @result[:weight] = calculate_weight
    @result[:address] = destination_address

    @result
  rescue StandardError
    handle_error
  end

  private

  def validate_delivery_date!(delivery_date)
    raise 'Дата доставки уже прошла' if delivery_date < Time.current
  end

  def validate_destination_address!(destination_address)
    raise 'Нет адреса' unless valid_address?(destination_address)
  end

  def valid_address?(address)
    [address.city, address.street, address.house].all?(&:present?)
  end

  def calculate_weight
    @order.products.map(&:weight).sum
  end

  def find_truck
    weight = calculate_weight
    TRUCKS.keys.find { |truck| TRUCKS[truck] > weight } || handle_no_truck!
  end

  def handle_no_truck!
    raise 'Нет машины'
  end

  def handle_error
    @result[:status] = :error

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

PrepareDelivery.new(Order.new, OpenStruct.new).perform(Address.new, Date.tomorrow)
