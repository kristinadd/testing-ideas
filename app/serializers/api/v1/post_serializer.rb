class Api::V1::PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :author, :created_at, :archived, :published

  def created_at
    object.created_at.strftime("%B %d, %Y")
  end

  attribute :word_count do
    object.content.split.length
  end

  attribute :reading_time do
    "#{(object.content.split.length / 200.0).ceil} min read"
  end

  def content
    object.content.length > 5 ? "#{object.content[0..5]}..." : object.content
  end

  def archived
    object.archived?
  end

  def published
    object.published?
  end
end
