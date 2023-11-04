class DeliveryProcessor
  def initialize(address, person, weight)
    @address = address
    @person = person
    @weight = weight
  end

  def setup_delivery
    Sdek.setup_delivery(address: @address, person: @person, weight: @weight)
  end
end
