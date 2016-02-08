module Contextuable
  class RequiredFieldNotPresent < ArgumentError; end
  class Base
    class << self
      def required(*names)
        @_required = names
      end

      def aliases(*names)
        @_equivalents ||= []
        @_equivalents << names.map(&:to_sym)
      end

      def defaults(hash)
        @_defaults = hash
      end
    end

    attr_reader :args

    def initialize(hash = {})
      fail ArgumentError unless hash.respond_to?(:fetch)
      fail RequiredFieldNotPresent unless _required_args.map(&:to_sym).all? { |r| hash.keys.map(&:to_sym).include?(r) }
      @args = _defaults.merge(hash)
      args.each do |k, v|
        define_singleton_method(k) { args.fetch(k) }
        define_singleton_method("#{k}?") { true }
      end
    end

    def method_missing(name, *args, &block)
      if ary = find_in_equivalents(name)
        _from_equivalents(ary)
      else
        name.to_s.include?('?') ? false : nil
      end
    end

    private

    def find_in_equivalents(name)
      found = nil
      _equivalents.each do |ary|
        found = ary if ary.include?(name.to_sym)
        break if found
      end
      found
    end

    def _from_equivalents(ary)
      out = nil
      ary.each do |method|
        out = args[method.to_sym]
        break if out
      end
      out
    end

    def _equivalents
      self.class.instance_variable_get(:@_equivalents) || []
    end

    def _defaults
      self.class.instance_variable_get(:@_defaults) || {}
    end

    def _required_args
      self.class.instance_variable_get(:@_required) || []
    end
  end
end
