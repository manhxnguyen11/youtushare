class Movie < ApplicationRecord
  belongs_to :user
  has_many :user_actions
end
