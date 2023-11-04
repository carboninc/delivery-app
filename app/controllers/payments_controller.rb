# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :product, only: :create

  def create
    payment_service = PaymentService.new(
      user: current_user,
      amount: params[:amount],
      product:,
      delivery: params[:delivery]
    )
    payment_service.perform
  end

  private

  def product
    @product ||= Product.find(params[:product_id])
  end
end
