require 'dcell'

module Elaine
  module Distributed
    class PostOffice
      include Celluloid
      include Celluloid::Logger

      attr_reader :mailboxes
      attr_reader :zipcodes

      def initialize
        @mailboxes = Hash.new
        @zipcodes = Hash.new
      end

      def zipcodes=(zipcodes)
        @zipcodes = zipcodes

        # do we need to initialize all the mailboxes here?
        # might be smart?
        @mailboxes = Hash.new
        my_id = DCell.me.id
        @zipcodes.each_pair do |k, v|
          if v == my_id
            debug "Creating mailbox for: #{k}"
            @mailboxes[k] = []
          end
        end

      end

      def address(to)
        # debug "There are: #{zipcodes.size} zipcodes"
        # debug "Looking up address for #{to}"
        # debug "Post office for #{to} is #{@zipcodes[to]}"
        node = DCell::Node[@zipcodes[to]]
      end


      def deliver(to, msg)
        
        node = address(to)

        if node.id.eql?(DCell.me.id)
          # debug "Delivering message to local mailbox: #{msg}"
          # @mailboxes[to] ||= []
          # debug "Mailboxes.size: #{@mailboxes.size}"
          # debug "Delivering to mailbox: #{to}"
          @mailboxes[to].push msg
        else
          # debug "Delivering message to remote mailbox: #{msg}"
          #DCell::Node[@zipcoes[to][:postoffice].deliver(to, msg)
          remote_post_office = node[:postoffice].deliver(to, msg)
          # remote_post_office.
        end
      end

      def read(mailbox)
        node = address(mailbox)
        if node.id.eql?(Dcell.me.id)
          @mailboxes[mailbox]
        else
          node[:postoffice].read mailbox
        end
      end

      def read_all(mailbox)
        node = address(mailbox)
        # debug "node: #{node}"
        # debug "node.id: '#{node.id}'"
        # debug "DCell.me.id: '#{DCell.me.id}'"
        if node.id.eql?(DCell.me.id)
          # @mailboxes.delete(mailbox) || []
          msgs = @mailboxes[mailbox].map { |v| v }
          @mailboxes[mailbox].clear
          msgs
        else
          raise "Can't destructively read a non-local mailbox!"
        end
      end

    end # class PostOffice
  end # module Distributed
end # module Elaine