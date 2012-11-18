class Comment < ActiveRecord::Base
  belongs_to :article

   attr_accessible :content, :author, :article_id, :article, :title
end