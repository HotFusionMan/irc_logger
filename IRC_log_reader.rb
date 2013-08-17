require 'rubygems'
require 'sinatra/base'
require 'thin'
require 'listen'


LOGFILE_PATH = File.absolute_path(File.dirname(__FILE__)) + '/IRC_log'

class IRCLogReader < Sinatra::Base
  enable :threaded

  Dir.chdir( LOGFILE_PATH )
  @@log_filenames = Dir.glob( 'IRC.log*' ).sort { |a, b| b <=> a }
cattr_accessor :log_filenames, :log_file_contents
  @@log_file_contents = {}


  template :index do
    t = <<-EOT
    <%
      Dir.chdir( LOGFILE_PATH )
      filenames = Dir.glob( 'IRC.log*' )
      IRCLogReader.log_filenames[1..-1].unshift( IRCLogReader.log_filenames[0] ).each do |filename|
      #filenames[1..-1].sort { |a, b| b <=> a }.unshift( filenames[0] ).each do |filename|
    %>
      <a href='<%= url(filename) %>'><%= filename %></a><br />
    <% end %>
    EOT
  end

  template :file do
    '<html><body><pre><%= @file_contents %></pre></body></html>'
  end

  get '/' do
    erb :index
  end

  get '/:filename' do
    filename = params[:filename]

    unless @file_contents = IRCLogReader.log_file_contents[filename]
      @file_contents = File.open( File.expand_path( filename, LOGFILE_PATH ) ) { |file| file.read }

      if filename =~ /\.\d+\Z/
        IRCLogReader.log_file_contents[filename] = @file_contents
      end
    end

    erb :file
  end
end


Listen.to( LOGFILE_PATH, :filter => /\AIRC\.log\./, :relative_paths => TRUE ) do |modified_paths, added_paths, removed_paths|
  IRCLogReader.log_filenames -= removed_paths
  IRCLogReader.log_filenames += added_paths
  IRCLogReader.log_filenames.sort! { |a, b| b <=> a }
end


IRCLogReader.new
