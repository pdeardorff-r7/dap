module Dap
  module Filter

  class FilterMemcachedVersion
    include Base

    def process(doc)
      out = []
      self.opts.each_pair do |k,v|
        next unless doc.has_key?(k)
        out << doc.merge({ 'version' => extract(doc[k]) })
      end
     out
    end

    def extract(data)
      if /^VERSION (?<version>[\d\.]+)/ =~ data
        version
      end
    end
  end

  class FilterMemcacheUsageStats
    include Base

    STAT_KEYS = %w(
      total_items
      bytes_written
      bytes_read
    )

    def process(doc)
      out = []
      self.opts.each_pair do |k,v|
        next unless doc.has_key?(k)
        out << doc.merge(extract(doc[k]))
      end
     out
    end

    # Returns hash of stat keys and
    # extracted values
    def extract(data)
      stats = Hash.new(STAT_KEYS)
      STAT_KEYS.each do |key|
        matches = /^STAT #{key} (?<value>(\.|\d)*)/.match(data)
        stats[key] = matches ? matches[:value] : ""
      end
      stats
    end
  end
  end
end
