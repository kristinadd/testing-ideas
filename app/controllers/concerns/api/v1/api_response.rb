module Api
  module V1
    module ApiResponse
      extend ActiveSupport::Concern

      def render_json_with_wrapper(data, options = {})
        data_array = data.respond_to?(:to_a) ? data.to_a : data

        if data_array.is_a?(Array)
          serialized_data = data_array.map { |item| Api::V1::PostSerializer.new(item).as_json }
        else
          serialized_data = Api::V1::PostSerializer.new(data_array).as_json
        end

        response = { data: serialized_data }

        if options[:pagination]
          response[:pagination] = options[:pagination]
        end

        render json: response
      end
    end
  end
end
