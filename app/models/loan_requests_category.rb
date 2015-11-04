class LoanRequestsCategory < ActiveRecord::Base
  belongs_to :loan_request
  belongs_to :category, :counter_cache => :loan_request_count
end
