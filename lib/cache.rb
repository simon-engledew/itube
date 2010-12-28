class Cache
  class << self
    def read(key, &block)
      if (value = self[key]).nil? and block_given?
        value = block.call
        self[key] = value
      end
      return value
    end

    def [](key)
      Rails.cache.read(key)
    end

    def []=(key, value)
      Rails.cache.write(key, value, :expires_at => 5.minutes)
    end

    def clear(key)
      Rails.cache.delete(key)
    end
  end
end