class CreateLineTesterCounts < ActiveRecord::Migration
  def change
    create_table :line_tester_counts do |t|
      t.integer :amount
    end
  end
end
