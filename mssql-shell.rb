#!/usr/bin/env ruby

require 'tiny_tds'
require 'optparse'
require 'colorize'
require 'readline'

trap('SIGINT') { puts "\n\nCTRL+C interrupt. Closing connection.".red; exit 666; }

options = {}
optparse = OptionParser.new do |opts|
  opts.banner << ' <dataserver>'
  opts.on('-u', '--user USER_ID', String, 'Connect with user id')
  opts.on('-p', '--pass PASSWORD', String, 'Connect with password')
end
optparse.parse!(into: options)

if ARGV.empty?
  puts(optparse)
  exit(1)
end

dataserver = ARGV.first

# Execute SQL command.
def execute(client, command)
  puts(command.blue)
  results = client.execute(command)
  return if results.nil? || results.fields.empty?

  fields = results.fields
  rows = results.map(&:values)

  # Calculate max lengths to align table.
  max_lengths = fields.map(&:length)
  rows.each do |row|
    row.each_with_index do |val, i|
      max_lengths[i] = [max_lengths[i], val.to_s.length].max
    end
  end

  # Print fields and rows in a table.
  fields.each_with_index { |c, i| printf("|%-#{max_lengths[i] + 4}s".green, c) }
  puts('|'.green)
  max_lengths.each { |ml| print("|#{'-' * (ml + 4)}".green) }
  puts('|'.green)
  rows.each do |row|
    row.each_with_index { |r, i| printf("|%-#{max_lengths[i] + 4}s", r) }
    puts('|')
  end
end

module Commands
  def self.xp_cmdshell(client, command)
    execute(client, "EXEC xp_cmdshell '#{command}';")
  end

  def self.enable_xp_cmdshell(client, _)
    execute(client, "EXEC sp_configure 'show advanced options', 1; RECONFIGURE;")
    execute(client, "EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;")
  end
end

begin
  client = TinyTds::Client.new(username: options[:user], password: options[:pass], dataserver: dataserver)
  puts("Connected to '#{dataserver}'.".green)

  while (buf = Readline.readline("#{dataserver}> ", true))
    exit if %w[exit quit].include?(buf)

    if buf.start_with?(':') # Custom commands.
      split = buf.split
      sym = split.first.delete(':').to_sym
      command = split[1..-1].join(' ')
      begin
        Commands.send(sym, client, command)
      rescue NoMethodError
        puts('Unknown command.'.red)
      end
    else
      execute(client, buf)
    end
  end
rescue TinyTds::Error => e
  puts("Error: #{e.message}".red)
  exit(1)
ensure
  puts('')
end
