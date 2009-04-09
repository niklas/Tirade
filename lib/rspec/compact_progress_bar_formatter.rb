# Copyright (c) 2008 Nicholas A. Evans
#  
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#  
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'spec/runner/formatter/base_text_formatter'
require "rubygems"
require 'progressbar'

module Spec
  module Runner
    module Formatter
      class CompactProgressBarFormatter < BaseTextFormatter
        # Threshold for slow specs, in seconds.
        # Anything that takes longer than this will be printed out
        #THRESHOLD = 0.25
        THRESHOLD = 5.0

        attr_reader :total, :current

        def start(example_count)
          @current     = 0
          @total       = example_count
          @error_state = :all_passing
          @pbar        = ProgressBar.new("#{example_count} examples", example_count, output)
        end

        def example_started(example)
          super
          @start_time = Time.now
        end

        def example_passed(example)
          print_warning_if_slow(example_group.description,
                                example.description,
                                Time.now - @start_time)
          increment
        end

        # third param is optional, because earlier versions of rspec sent only two args
        def example_pending(example, message, pending_caller=nil)
          immediately_dump_pending(example.full_description, message, pending_caller)
          mark_error_state_pending
          increment
        end

        def example_failed(example, counter, failure)
          immediately_dump_failure(counter, failure)
          mark_error_state_failed
          increment
        end

        def start_dump
          with_color do
            @pbar.finish
          end
          output.flush
        end

        def dump_failure(*args)
          # no-op; we summarized failures as we were running
        end

        def method_missing(sym, *args)
          # ignore
        end

        # stolen and slightly modified from BaseTextFormatter#dump_failure
        def immediately_dump_failure(counter, failure)
          erase_current_line
          output.print "#{counter.to_s}) "
          output.puts colourise("#{failure.header}\n#{failure.exception.message}", failure)
          output.puts format_backtrace(failure.exception.backtrace)
          output.puts
        end

        # stolen and modified from BaseTextFormatter#dump_pending
        def immediately_dump_pending(desc, msg, called_from)
          erase_current_line
          output.puts yellow("PENDING SPEC:") + " #{desc} (#{msg})"
          output.puts "  Called from #{called_from}" if called_from
        end

        def increment
          with_color do
            @current += 1
            # HACK: need to make sure the progress is printed, even when the bar hasn't changed
            @pbar.instance_variable_set("@previous", 0)
            @pbar.instance_variable_set("@title", "#{current}/#{total}")
            @pbar.inc
          end
          output.flush
        end

        ERROR_STATE_COLORS = {
          :all_passing  => "\e[32m", # green
          :some_pending => "\e[33m", # yellow
          :some_failed  => "\e[31m", # red
        }

        def with_color
          use_color = colour? && output_to_tty?
          output.print ERROR_STATE_COLORS[@error_state] if use_color
          yield
          output.print "\e[0m" if use_color
        end

        def mark_error_state_failed
          @error_state = :some_failed
        end

        def mark_error_state_pending
          @error_state = :some_pending unless @error_state == :some_failed
        end

        def erase_current_line
          output.print "\e[K"
        end

        def print_warning_if_slow(group, example, elapsed)
          if elapsed > THRESHOLD
            #mark_error_state(:pending)
            erase_current_line
            output.print yellow("SLOW SPEC: #{sprintf("%.4f", elapsed)} ")
            output.print " #{group} #{example}"
            output.puts
          end
        end

      end
    end
  end
end
