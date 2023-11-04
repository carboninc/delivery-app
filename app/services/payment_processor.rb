class PaymentProcessor
  def initialize(user:, amount:)
    @user = user
    @amount = amount
  end

  def process_payment
    CloudPayment.proccess(
      user_uid: @user.cloud_payments_uid,
      amount_cents: @amount * 100,
      currency: 'RUB'
    )
  end
end
