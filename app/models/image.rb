class Image < ActiveRecord::Base
  belongs_to :article
  attr_accessible :original_url, :article_id, :article, :article_image_flag
end