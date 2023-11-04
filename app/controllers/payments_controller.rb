def create
  product = Product.find(params[:product_id])
  payment_result = CloudPayment.proccess(
    user_uid: current_user.cloud_payments_uid,
    amount_cents: params[:amount] * 100,
    currency: 'RUB'
  )

  if payment_result[:status] == 'completed'
    delivery = Sdek.setup_delivery(address:, person:, weight:)

    if delivery[:result] == 'succeed'
      DeliveryMailer.sdek_delivery(delivery).deliver_later
    else
      redirect_to :failed_payment_path, note: 'Не удалось оформить доставку'
    end

    product_access = ProductAccess.create(user: current_user, product:)
    OrderMailer.product_access_email(product_access).deliver_later
    redirect_to :successful_payment_path
  else
    redirect_to :failed_payment_path, note: 'Что-то пошло не так'
  end
end