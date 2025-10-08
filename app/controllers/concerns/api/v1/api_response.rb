module Api
  module V1
    module ApiResponse
      extend ActiveSupport::Concern

      def render_json_with_wrapper(serializer_class, collection, options = {})
        collection_array = collection.respond_to?(:to_a) ? collection.to_a : collection

        if collection_array.is_a?(Array)
          serialized_collection = collection_array.map { |item| serializer_class.new(item).as_json }
        else
          serialized_collection = serializer_class.new(collection_array).as_json
        end

        response = { collection: serialized_collection }

        if options[:pagination]
          response[:pagination] = options[:pagination]
        end

        render json: response
      end
    end
  end
end
