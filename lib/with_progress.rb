module OpenGov
  module Helpers
    def with_progress(options={})
      options[:before] ||= ""  # Message to print before starting
      options[:after]  ||= ""  # Message to print after completion
      options[:char]   ||= '.' # Character to be printed as progress
      options[:rate]   ||= 0.2 # Delay between printing :char option
      options[:change] ||= 1   # Allows for the rate to accelerate/decelerate

      print options[:before]

      thread = Thread.new do
        printer = proc do |interval|
          print(options[:char])
          $stdout.flush
          sleep interval
          printer.call [interval * options[:change], 0.01].max
        end
        printer.call options[:rate]
      end

      yield and thread.kill

      puts options[:after]
    end
  end
end
