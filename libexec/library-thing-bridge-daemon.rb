# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
  config.trap( 'INT', Proc.new { puts 'Going down' } )
end

sp = FileBasedSerial.new(File.join(File.dirname(__FILE__), '..', 'requests.json'))
ids = FileBasedIdService.new(File.join(File.dirname(__FILE__), '..', 'id_db.json'))
lms = PrintingLibraryManagementService.new(File.join(File.dirname(__FILE__), '..', 'books.json'))
mh = MessageHandler.new(ids, lms)
mp = MessagePump.new(sp, mh)
worker = Worker.new(mp)

worker.run
