class ApplicationService
  # Base class for all services
  # You can add common service functionality here

  def self.call(*args, &block)
    new(*args, &block).call
  end
end
