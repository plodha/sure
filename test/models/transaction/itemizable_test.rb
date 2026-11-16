require "test_helper"

class Transaction::ItemizableTest < ActiveSupport::TestCase
  include EntriesTestHelper

  setup do
    @entry = create_transaction(amount: 10)
    @transaction = @entry.entryable
  end

  test "items are returned in position order" do
    @transaction.items.create!(name: "Second", amount: 3, position: 1)
    @transaction.items.create!(name: "First", amount: 2, position: 0)

    assert_equal %w[First Second], @transaction.items.reload.map(&:name)
  end

  test "items_total sums line amounts and tax" do
    @transaction.items.create!(name: "Milk", amount: 4.25, tax_amount: 0.25)
    @transaction.items.create!(name: "Bread", amount: 5)

    assert_equal BigDecimal("9.5"), @transaction.items_total
  end

  test "items_match_amount? is true when items add up to the entry amount" do
    @transaction.items.create!(name: "Milk", amount: 4)
    @transaction.items.create!(name: "Bread", amount: 6)

    assert @transaction.items_match_amount?
  end

  test "items_match_amount? allows one cent of rounding" do
    @transaction.items.create!(name: "Milk", amount: 9.99)

    assert @transaction.items_match_amount?
  end

  test "items_match_amount? is false when items are short" do
    @transaction.items.create!(name: "Milk", amount: 4)

    assert_not @transaction.items_match_amount?
  end

  test "items_match_amount? is false without items" do
    assert_not @transaction.items_match_amount?
  end

  test "items_match_amount? compares against the absolute entry amount" do
    income = create_transaction(amount: -10).entryable
    income.items.create!(name: "Refund", amount: 10)

    assert income.items_match_amount?
  end

  test "destroying the entry destroys its transaction items" do
    @transaction.items.create!(name: "Milk", amount: 4)

    assert_difference -> { Transaction::Item.count }, -1 do
      @entry.destroy!
    end
  end
end
