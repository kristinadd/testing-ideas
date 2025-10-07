class AddAtributesToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :status, :string, default: 'draft'
    add_column :posts, :published_at, :datetime
  end
end
