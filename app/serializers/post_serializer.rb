class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :author, :created_at, :updated_at
  
  # Custom formatting for dates
  def created_at
    object.created_at.iso8601
  end
  
  def updated_at
    object.updated_at.iso8601
  end
  
  # Computed attributes
  attribute :word_count do
    object.content.split.length
  end
  
  attribute :reading_time do
    "#{(object.content.split.length / 200.0).ceil} min read"
  end
  
  # Conditional attributes based on context
  attribute :content do
    if scope&.admin?
      object.content
    else
      # Truncate content for non-admin users
      object.content.length > 100 ? "#{object.content[0..100]}..." : object.content
    end
  end
end
