# One purchased line on a transaction, such as a single grocery item from a
# receipt. `amount` is the line total before tax; `tax_amount` is optional.
# Currency is the parent transaction's entry currency.
class Transaction::Item < ApplicationRecord
  belongs_to :parent_transaction, class_name: "Transaction", foreign_key: :transaction_id, inverse_of: :items
  belongs_to :category, optional: true

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :amount, numericality: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :tax_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def total
    amount + tax_amount.to_d
  end
end
