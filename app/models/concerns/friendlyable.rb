# https://hackernoon.com/how-to-use-hash-ids-in-your-url-in-ruby-on-rails-5-e8b7cdd31733
# To use friendly IDs for a model:
# 1. When generating the model, include hash_id:string:index as one of the
#    fields.
# 2. Add `include Friendlyable` to the top of its class definition.
# 3. Everywhere you're doing `.find`, use `.friendly.find` instead.

module Friendlyable
  extend ActiveSupport::Concern
  included do 
    extend ::FriendlyId
    before_create :set_hash_id
    friendly_id :hash_id
  end

  def set_hash_id
    hash_id = nil
    loop do
      hash_id = SecureRandom.urlsafe_base64(9).gsub(/-|_/,('a'..'z').to_a[rand(26)])
      break unless self.class.name.constantize.where(:hash_id => hash_id).exists?
    end
    self.hash_id = hash_id
  end
end
