module ApiResponse
  extend ActiveSupport::Concern

  def render_json_with_wrapper(data, options = {})
    if data.is_a?(Array)
      # For collections (arrays)
      serialized_data = data.map { |item| Api::V1::PostSerializer.new(item).as_json }
    else
      # For single objects
      serialized_data = Api::V1::PostSerializer.new(data).as_json
    end

    response = { data: serialized_data }

    # Add metadata
    if options[:meta]
      response[:meta] = options[:meta]
    end

    # Add pagination links
    if options[:links]
      response[:links] = options[:links]
    end

    # Add version info
    response[:version] = "1.0"
    response[:timestamp] = Time.current.iso8601

    render json: response
  end
end
