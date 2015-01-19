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
    matches = /^STAT (?<version>version (\.|\d)*)/.match(data)
    (matches[:version] if matches) || 'unknown'
  end
end

end
end
