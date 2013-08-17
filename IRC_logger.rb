require 'rubygems'
require 'ponder'
require 'daemons'

LOGFILE_PATH = File.absolute_path(File.dirname( __FILE__ )) + '/IRC_log/IRC.log'

Daemons.run_proc( 'IRC_logger.rb', :backtrace  => TRUE, :monitor => TRUE ) do
  @thaum = Ponder::Thaum.new do |config|
    config.server    = 'aux.new.edu'
    config.username  = 'Lumberjack'
    config.nick      = 'Lumberjack'
    config.real_name = 'Ponder'
    config.logging   = TRUE
    config.logger    = Ponder::Logging::Twoflogger.new( LOGFILE_PATH, 'daily' )
    config.rejoin_after_kick = TRUE
  end

  @thaum.on :connect do
    @thaum.join '#product'
    @thaum.away "and I'm OK"
  end

  @thaum.connect
end
