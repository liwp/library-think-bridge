# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

class Worker
  def initialize(message_pump)
    @message_pump = message_pump
  end

  def run
    loop do
      return if @shutting_down
      @message_pump.handle_message
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

  def handle_message
    DaemonKit.logger.info "waiting for message..."
    message = @serial.read_message
    DaemonKit.logger.info "read message"
    @message_handler.handle_message(message)
  end
end

class Serial
  def read_message
  end
end

class MessageHandler
  def handle_message
  end
end
