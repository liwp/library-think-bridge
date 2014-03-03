require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
describe MessagePump do
  before(:each) do
    @serial = double("serial")
    @message_handler = double("message handler")
  end
  
  it "reads message from serial port" do
    mp = MessagePump.new(@serial, @message_handler)

    expect(@serial).to receive(:read_message)
    expect(@message_handler).to receive(:handle_message)

    mp.handle_message
  end

  it "delegates message to message handler" do
    mp = MessagePump.new(@serial, @message_handler)

    expect(@serial).to receive(:read_message).and_return(:fake_message)
    expect(@message_handler).to receive(:handle_message).with(:fake_message)

    mp.handle_message
  end
end
