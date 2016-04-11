module JsonKVParser

  def select_from(where, key)
    raise Nilavu::InvalidParameters unless where

    where.select { |i|  i[:key].to_sym == key.to_sym }
  end

  def select_with_pattern(where, pattern)
    raise Nilavu::InvalidParameters unless where
    return if (where.select{ |k,v|  k[:key].include?(pattern) }).empty?
    where.select{ |k,v|  k[:key].include?(pattern) }
  end

  def ensure_symbolized(where)
    where.map{|ij| ij.symbolize_keys}
  end
end
