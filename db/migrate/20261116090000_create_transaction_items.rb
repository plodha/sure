class CreateTransactionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :transaction_items, id: :uuid do |t|
      t.references :transaction, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :category, foreign_key: { on_delete: :nullify }, type: :uuid
      t.integer :position, null: false, default: 0
      t.string :name, null: false
      t.decimal :quantity, precision: 19, scale: 4, null: false, default: 1
      t.decimal :unit_price, precision: 19, scale: 4
      t.decimal :amount, precision: 19, scale: 4, null: false
      t.decimal :tax_amount, precision: 19, scale: 4

      t.timestamps
    end
  end
end
