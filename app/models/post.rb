class Post < ApplicationRecord
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :author, presence: true, length: { maximum: 255 }

  has_many :comments, dependent: :destroy

  enum :status, {
    draft: "draft",
    published: "published",
    archived: "archived"
  }
end
