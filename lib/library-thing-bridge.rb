# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

class Worker
  def initialize(message_pump)
    @message_pump = message_pump
  end

  def run
    catch :done do
      loop do
        return if @shutting_down
        @message_pump.handle_request
      end
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

class MessageHandler
  def initialize(id_service, library_management_service)
    @id_service = id_service
    @library_management_service = library_management_service
  end

  def handle_request(request)
    case request[:type]
    when "tag_req"
      @id_service.lookup(request[:tag])
    when "borrow_req"
      @library_management_service.borrow(request[:book])
    when "return_req"
      @library_management_service.return(request[:book])
    else
      DaemonKit.logger.info "Unknown request type: #{request[:type]}"
      raise "Unknown request type: #{request[:type]}"
    end
  end
end

class PrintingLibraryManagementService
  def initialize(file_name)
    entries = JSON.parse(IO.read(file_name), :symbolize_names => true)
    @books = entries.each_with_object({}) { |v,h| h[v[:isbn]] = v }
    DaemonKit.logger.info("PrintingLibraryManagementService - DB: #{@books}")
  end

  def borrow(book_isbn)
    book = @books[book_isbn]
    puts "borrow book: #{book}"
    book
  end

  def return(book_isbn)
    puts "return book: #{book_isbn}"
  end
end

class FileBasedIdService
  def initialize(file_name)
    entries = JSON.parse(IO.read(file_name), :symbolize_names => true)
    @db = entries.each_with_object({}) { |v,h| h[v[:tag]] = v }
  end

  def lookup(tag)
    DaemonKit.logger.info("FileBasedIdService - lookup: #{tag.inspect}")
    id = @db[tag]
    DaemonKit.logger.info("FileBasedIdService - found id: #{id}")
    id
  end
end

class FileBasedSerial
  def initialize(file_name)
    @requests = JSON.parse(IO.read(file_name), :symbolize_names => true)
  end

  def read_request
    throw :done if @requests.empty?
    @requests.shift
  end

  def write_response(rsp)
    DaemonKit.logger.info("FileBasedSerial: #{rsp}")
  end
end
