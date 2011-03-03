class Cache
  class << self
    def read(key, &block)
      if (value = self[key]).nil? and block_given?
        value = block.call
        self[key] = value
      end
      return value
    end
    
    def sanitize(key)
      raise 'empty key' if key.blank?
      Base64.encode64(key)
    end

    def [](key)
      Rails.cache.read(sanitize(key))
    end

    def []=(key, value)
      Rails.cache.write(sanitize(key), value, :expires_at => 5.minutes)
    end

    def clear(key)
      Rails.cache.delete(sanitize(key))
    end
  end
end