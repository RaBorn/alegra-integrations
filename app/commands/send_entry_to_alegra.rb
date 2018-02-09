class SendEntryToAlegra < PowerTypes::Command.new(:entry)
  def perform
    send
    mark_as_synced
  end

  private

  def send
    AlegraClient.new.post('payments/', alegra_payload)
  end

  def mark_as_synced
    @entry.update(alegra_status: :synced)
  end

  def alegra_payload
    {
      date: @entry.date,
      bankAccount: alegra_bank_acount_id,
      type: @entry.amount.positive? ? 'in' : 'out',
      anotation: @entry.description,
      observations: @entry.amount.to_f.abs,
      paymentMethod: 'transfer',
      categories: [payment_category]
    }
  end

  def payment_category
    {
      id: @entry.amount.positive? ? 30 : 5039,
      quantity: 1,
      price: @entry.amount.to_f.abs
    }
  end

  def alegra_bank_acount_id
    @entry.product.alegra_id
  end
end
