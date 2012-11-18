class Category < ActiveRecord::Base
  has_many :articles
  attr_accessible :id, :title, :legacy_id, :parent_id
end