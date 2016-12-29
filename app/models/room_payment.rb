module RoomPayment
  def create_escrow_payment_message
    msg = messages.create(body: "/charge $#{escrow_amount}", user: manager, msg_type: 'bot-half-charge-task')
    msg.process_command
  end

  # client
  def client_budget
    amount = budget_cents
    amount = budget_cents_including_fee if kriya_client_fee_cents_calculated == kriya_client_fee_cents
    amount / 100
  end

  def client_balance
    balance = budget_cents - first_paid_amount_cents + kriya_client_fee_cents
    balance = budget_cents_including_fee - first_paid_amount_cents if kriya_client_fee_cents_calculated == kriya_client_fee_cents
    balance / 100
  end

  def set_kriya_client_fee_cents
    self.update_columns(kriya_client_fee_cents: kriya_client_fee_cents_calculated)
  end

  def kriya_client_fee_cents_calculated
    percentag = 10
    percentag = 5 if self.budget_cents >= 500_00

    self.budget_cents * percentag / 100
  end

  def remaining_amount_cents
    budget_cents_including_fee - first_paid_amount_cents
  end

  def budget_cents_including_fee
    kriya_client_fee_cents + budget_cents
  end

  def first_paid_amount_percentag
    if budget_cents_including_fee < 1000_00
      50
    elsif budget_cents_including_fee >= 1000_00 && budget_cents_including_fee < 5000_00
      25
    elsif budget_cents_including_fee >= 5000_00 && budget_cents_including_fee < 10_000_00
      20
      # elsif budget_cents >= 10_000_00
    else
      15
    end
  end

  def escrow_amount_cents
    budget_cents_including_fee.to_f * first_paid_amount_percentag / 100
  end

  def escrow_amount
    escrow_amount_cents / 100
  end

  # freelancer
  def freelancer_budget
    amount = budget_cents
    amount = budget_cents_including_fee - freelancer_fee_cents if kriya_client_fee_cents_calculated == kriya_client_fee_cents
    amount / 100
  end

  def freelancer_balance
    balance = 0
    balance = client_balance - (client_balance * freelancer_fee_percentage / 100) if kriya_client_fee_cents_calculated == kriya_client_fee_cents
    balance
  end

  def freelancer_fee_cents
    budget_cents_including_fee * freelancer_fee_percentage / 100
  end

  def freelancer_fee_percentage
    # 20% until 5K or 15% until 10K or 5% > 10K
    if budget_cents_including_fee < 5_000_00
      20
    elsif budget_cents_including_fee >= 5_000_00 && budget_cents_including_fee < 10_000_00
      15
    # 5% > 10K
    else
      5
    end
  end
end
