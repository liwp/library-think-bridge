require File.dirname(__FILE__) + '/spec_helper.rb'

describe MessagePump do
  before(:each) do
    @serial = double("serial")
    @message_handler = double("message handler")
  end
  
  it "reads message from serial port" do
    mp = MessagePump.new(@serial, @message_handler)

    expect(@serial).to receive(:read_request)
    expect(@message_handler).to receive(:handle_request)
    expect(@serial).to receive(:write_response)

    mp.handle_request
  end

  it "delegates message to message handler" do
    mp = MessagePump.new(@serial, @message_handler)

    expect(@serial).to receive(:read_request).and_return(:fake_request)
    expect(@message_handler).to receive(:handle_request).with(:fake_request)
    expect(@serial).to receive(:write_response)

    mp.handle_request
  end


  it "writes message handler response to serial" do
    mp = MessagePump.new(@serial, @message_handler)

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

    mp.handle_request
  end
end
