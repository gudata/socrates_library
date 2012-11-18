class Article < ActiveRecord::Base
  belongs_to :category
  has_many :images

   attr_accessible :id, :title, :legacy_id, :content, :category, :category_id, :author, :date
end