module Transaction::Itemizable
  extend ActiveSupport::Concern

  # Rounding slack when comparing line items to the entry amount.
  ITEMS_MATCH_TOLERANCE = BigDecimal("0.01")

  included do
    has_many :items, -> { order(:position, :created_at) },
             class_name: "Transaction::Item",
             foreign_key: :transaction_id,
             inverse_of: :parent_transaction,
             dependent: :destroy
  end

  def items_total
    items.sum(&:total)
  end

  # True when the line items, including tax, add up to the entry amount.
  def items_match_amount?
    items.any? && (entry.amount.abs - items_total).abs <= ITEMS_MATCH_TOLERANCE
  end
end
