class Post < ApplicationRecord
  has_many :comments, dependent: :destroy

  enum :status, {
    draft: "draft",
    published: "published",
    archived: "archived"
  }
end
