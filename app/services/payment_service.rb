class PaymentService
  def initialize(user:, amount:, product:, delivery:)
    @user = user
    @amount = amount
    @product = product
    @delivery = delivery
  end
    
  def perform
    payment_result = payment_processor.process_payment
    delivery_result = delivery_processor.setup_delivery

    if payment_result[:status] == 'completed' && delivery_result[:result] == 'succeed'
      perform_successful_payment_actions
    else
      handle_failed_payment(delivery_result)
    end
  end
    
  private

  def payment_processor
    @payment_processor ||= PaymentProcessor.new(user: @user, amount: @amount)
  end

  def delivery_processor
    @delivery_processor ||= DeliveryProcessor.new(address: @delivery[:address], person: @delivery[:person], weight: @delivery[:weight])
  end
    
  def perform_successful_payment_actions
    product_access = create_product_access(product)
    send_emails(product_access, delivery_result)
    redirect_to :successful_payment_path
  end

  def create_product_access(product)
    ProductAccess.create(user: @user, product: product)
  end

  def send_emails(product_access, delivery_result)
    OrderMailer.product_access_email(product_access).deliver_later
    DeliveryMailer.sdek_delivery(delivery_result).deliver_later
  end

  def handle_failed_payment(delivery_result)
    if delivery_result[:result] == 'failed'
      redirect_to :failed_payment_path, note: 'Не удалось оформить доставку'
    else
      redirect_to :failed_payment_path, note: 'Что-то пошло не так'
    end
  end
end
