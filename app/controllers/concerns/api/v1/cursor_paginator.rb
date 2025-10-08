module Api
  module V1
    module CursorPaginator
      extend ActiveSupport::Concern

      private

      def paginate_with_cursor(collection, options = {})
        # Get cursor and limit from options or params
        cursor = options[:cursor] || params[:cursor]&.to_i
        limit = options[:limit] || params[:limit]&.to_i || 2

        limit = [ limit, 50 ].min

        if cursor
          collection = collection.where("id > ?", cursor)
        end

        records = collection.limit(limit + 1)

        has_next = records.count > limit

        # Remove the extra record if we got it
        records = records.first(limit) if has_next

        # Calculate next cursor (ID of the last record)
        next_cursor = records.last&.id if has_next

        # Build pagination info
        pagination_info = {
          next_cursor: next_cursor,
          has_next: has_next,
          limit: limit
        }

        # Add current cursor for reference
        pagination_info[:current_cursor] = cursor if cursor

        # Return both records and pagination info
        {
          records: records,
          pagination: pagination_info
        }
      end
    end
  end
end
