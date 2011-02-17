require 'cache/version'
module Cache
  autoload :Config, 'cache/config'
  autoload :Storage, 'cache/storage'
  
  def self.config #:nodoc:
    Config.instance
  end

  # Get a value.
  #
  # Example:
  #     Cache.get 'hello'
  def self.get(k)
    Storage.instance.get k
  end
  
  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     Cache.set 'hello', 'world'
  #     Cache.set 'hello', 'world', 80 # seconds til it expires
  def self.set(k, v, ttl = nil)
    Storage.instance.set k, v, ttl
  end
  
  # Delete a value.
  #
  # Example:
  #     Cache.delete 'hello'
  def self.delete(k)
    Storage.instance.delete k
  end
  
  # Flush the cache.
  #
  # Example:
  #     Cache.flush
  def self.flush
    Storage.instance.flush
  end
end
