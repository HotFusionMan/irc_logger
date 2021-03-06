require 'rubygems'

require 'securerandom'
ENV['SESSION_SECRET'] = SecureRandom.base64(1024)

ENV['GOOGLE_AUTH_DOMAIN'] = 'unow.com'

require 'sinatra/base'
require 'sinatra/google-auth'
require 'thin'


LOGFILE_PATH = File.absolute_path(File.dirname(__FILE__)) + '/IRC_log'


class IRCLogReader < Sinatra::Base
  enable :threaded
  register Sinatra::GoogleAuth

  Dir.chdir( LOGFILE_PATH )
  @@log_filenames = Dir.glob( 'IRC.log*' ).sort { |a, b| b <=> a }

  @@log_file_contents = {}


  template :index do
      #@@log_filenames[1..-1].unshift( filenames[0] ).each do |filename|
    t = <<-EOT
    <%
      Dir.chdir( LOGFILE_PATH )
      filenames = Dir.glob( 'IRC.log*' )
      filenames[1..-1].sort { |a, b| b <=> a }.unshift( filenames[0] ).each do |filename|
    %>
      <a href='<%= url(filename) %>'><%= filename %></a><br />
    <% end %>
    EOT
  end


  template :file do
    '<html><body><pre><%= @file_contents %></pre></body></html>'
  end


  get '/' do
    authenticate
    erb :index
  end

  get '/:filename' do
    authenticate

    filename = params[:filename]

    unless @file_contents = @@log_file_contents[filename]
      @file_contents = File.open( File.expand_path( filename, LOGFILE_PATH ) ) { |file| file.read }

      if filename =~ /\.\d+\Z/
        @@log_file_contents[filename] = @file_contents
      end
    end

    erb :file
  end
end


Listen.to( LOGFILE_PATH, :filter => /\AIRC\.log\./, :relative_paths => TRUE ) do |modified_paths, added_paths, removed_paths|
  @@log_filenames += ( added_paths + removed_paths ) #.map { |path| File.basename( path ) }
  @@log_filenames.sort! { |a, b| b <=> a }
end
