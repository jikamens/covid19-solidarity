class Request < ApplicationRecord
  before_save :check_completed
  include Friendlyable
  belongs_to :user
  validates :payment_info, presence: true
  validates :amount, presence: true, :numericality => { :greater_than => 0 }
  validates :description, presence: true

  private

  def check_completed
    # XXX Can't build this until contributions are implemented
  end
end
