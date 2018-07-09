class CreateShortenedUrls < ActiveRecord::Migration
  def change
    create_table :shortened_urls do |t|
      t.text :original_url
      t.string :short_url
      t.string :sanitize_url
      t.integer :visited, :default => 0
      t.timestamps null: false
    end
  end
end
