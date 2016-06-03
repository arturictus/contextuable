class Contextuable
  module Helpers
    # Returns a new hash with all keys converted using the +block+ operation.
    #
    #  hash = { name: 'Rob', age: '28' }
    #
    #  transform_keys(hash) { |key| key.to_s.upcase } # => {"NAME"=>"Rob", "AGE"=>"28"}
    #
    # If you do not provide a +block+, it will return an Enumerator
    # for chaining with other methods:
    #
    #  hash.transform_keys(hash).with_index { |k, i| [k, i].join } # => {"name0"=>"Rob", "age1"=>"28"}
    def transform_keys(hash)
      return enum_for(:transform_keys) { hash.size } unless block_given?
      result = {}
      hash.each_key do |key|
        result[yield(key)] = hash[key]
      end
      result
    end
  end
end
