class AddLoanRequestCountToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :loan_request_count, :integer
  end
end
