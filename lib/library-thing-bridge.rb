# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

class Worker
  def initialize(message_pump)
    @message_pump = message_pump
  end

  def run
    loop do
      return if @shutting_down
      @message_pump.handle_request
    end
  end

  def shutdown
    @shutting_down = true
  end
end

class MessagePump
  def initialize(serial, message_handler)
    @serial = serial
    @message_handler = message_handler
  end

  def handle_request
    DaemonKit.logger.info "waiting for message..."
    req = @serial.read_request
    DaemonKit.logger.info "handle request"
    rsp = @message_handler.handle_request(req)
    DaemonKit.logger.info "handle response"
    @serial.write_response(rsp)
  end
end

class Serial
  def read_request
  end

  def write_response
  end
end

class MessageHandler
  def initialize(id_service, library_management_service)
    @id_service = id_service
    @library_management_service = library_management_service
  end

  def handle_request(request)
    case request.type
    when :tag_req
      @id_service.lookup_tag(request)
    when :borrow_req
      @library_management_service.borrow(request)
    when :return_req
      @library_management_service.return(request)
    else
      DaemonKit.logger.info "Unknown retuest type: #{request.type}"
    end
  end
end

Request = Struct.new(:type)
