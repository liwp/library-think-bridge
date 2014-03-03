require File.dirname(__FILE__) + '/spec_helper.rb'

describe MessageHandler do
  before(:each) do
    @tag_service = double("tag service")
    @library_service = double("library management service")
    @mh = MessageHandler.new(@tag_service, @library_service)
  end

  it "delegates tag requests to id service" do
    req = { :type => "tag_req", :tag => :tag_value }

    expect(@tag_service).
      to receive(:lookup).
      with(:tag_value).
      and_return(:lookup_rsp)

    expect(@mh.handle_request(req)).to be(:lookup_rsp)
  end

  it "delegates borrow requests to library service" do
    req = { :type => "borrow_req", :book => :book_isbn }

    expect(@library_service).
      to receive(:borrow).
      with(:book_isbn).
      and_return(:borrow_rsp)

    expect(@mh.handle_request(req)).to be(:borrow_rsp)
  end

  it "delegates return requests to library service" do
    req = { :type => "return_req", :book => :book_isbn }

    expect(@library_service).
      to receive(:return).
      with(:book_isbn).
      and_return(:return_rsp)

    expect(@mh.handle_request(req)).to be(:return_rsp)
  end
end

describe MessagePump do
  before(:each) do
    @serial = double("serial")
    @message_handler = double("message handler")
    @mp = MessagePump.new(@serial, @message_handler)
  end
  
  it "reads message from serial port" do
    expect(@serial).to receive(:read_request)
    expect(@message_handler).to receive(:handle_request)
    expect(@serial).to receive(:write_response)

    @mp.handle_request
  end

  it "delegates message to message handler" do
    expect(@serial).to receive(:read_request).and_return(:fake_request)
    expect(@message_handler).to receive(:handle_request).with(:fake_request)
    expect(@serial).to receive(:write_response)

    @mp.handle_request
  end

  it "writes message handler response to serial" do
    expect(@serial).
      to receive(:read_request).
      and_return(:fake_request)
    expect(@message_handler).
      to receive(:handle_request).
      with(:fake_request).
      and_return(:fake_response)
    expect(@serial).
      to receive(:write_response).
      with(:fake_response)

    @mp.handle_request
  end
end
