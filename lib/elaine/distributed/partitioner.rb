# require 'dnssd'
# require 'celluloid/io'
# require 'dcell'

module Elaine
  module Distributed
    # this might serve better as a module that gets included?

    # Partitions into ranges...
    class Partitioner

      # get the key for a given value.
      # for this partitioner, it's just the value itself, but you can perhaps
      # hash something too...
      def self.key(v)
        v
      end

      def self.partition(vals, num_partitions)
        partitions = Array.new(num_partitions)


        # this is a really poor implementation....
        vals.each_with_index do |v, idx|
          partition = idx % num_partitions
          
          partitions[partition] ||= 0
          partitions[partition] += 1
        end

        # now we know how many vertices should be in each partition...

        # HACK - again not very efficient...
        # TODO should really look into bloom filters or something
        partition_ranges = Array.new(num_partitions)
        local_count = 0
        partition_num = 0
        min_val = nil
        max_val = nil
        vals.sort.each do |v|
          if partitions[partition_num] <= local_count
            # we need to move to the next partition
            partition_ranges[partition_num] = (min_val..max_val)
            min_val = nil
            max_val = nil
            partition_num += 1
            local_count = 0
          end
          min_val ||= v
          min_val = v if v < min_val

          # HACK this can get ugly if there is only one vertex in a given
          # partition...
          max_val ||= v
          max_val = v if v > max_val
          local_count += 1

        end
        
        partition_ranges
      end
    end # class Partitioner
  end # module Distributed
end # module Elaine
