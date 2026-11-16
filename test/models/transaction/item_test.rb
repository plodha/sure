require "test_helper"

class Transaction::ItemTest < ActiveSupport::TestCase
  include EntriesTestHelper

  setup do
    @transaction = create_transaction(amount: 10).entryable
  end

  test "is valid with a name and amount" do
    item = Transaction::Item.new(parent_transaction: @transaction, name: "Whole milk", amount: 4.25)

    assert item.valid?
    assert_equal 1, item.quantity
  end

  test "requires a name" do
    item = Transaction::Item.new(parent_transaction: @transaction, name: "", amount: 4.25)

    assert_not item.valid?
    assert item.errors.key?(:name)
  end

  test "requires a positive quantity" do
    item = Transaction::Item.new(parent_transaction: @transaction, name: "Whole milk", amount: 4.25, quantity: 0)

    assert_not item.valid?
    assert item.errors.key?(:quantity)
  end

  test "rejects negative tax" do
    item = Transaction::Item.new(parent_transaction: @transaction, name: "Whole milk", amount: 4.25, tax_amount: -1)

    assert_not item.valid?
    assert item.errors.key?(:tax_amount)
  end

  test "total adds tax to the line amount" do
    item = Transaction::Item.new(amount: 4.25, tax_amount: 0.34)

    assert_equal BigDecimal("4.59"), item.total
  end

  test "total treats missing tax as zero" do
    assert_equal BigDecimal("4.25"), Transaction::Item.new(amount: 4.25).total
  end
end
