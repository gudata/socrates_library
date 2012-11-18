class Initial < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content

      t.string :legacy_id
      t.string :author
      t.datetime :date

      t.belongs_to :category

      t.timestamps
    end

    create_table :categories do |t|
      t.string :title

      t.string :legacy_id

      t.integer :parent_id
    end

    create_table :images do |t|
      t.string :original_url
      t.boolean :article_image_flag
      t.belongs_to :article
    end

    create_table :comments do |t|
      t.string :title
      t.string :content
      t.string :author
      t.datetime :date

      t.belongs_to :article
    end
  end
end
