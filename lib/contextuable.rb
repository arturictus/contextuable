# require 'forwardable'
class Contextuable
  # extend Forwardable
  # delegate :[], to: :args

  VERSION = "0.1.0"
  class RequiredFieldNotPresent < ArgumentError; end
  class PresenceRequired < ArgumentError; end
  class << self
    def required(*names)
      @_required = names
    end

    def ensure_presence(*names)
      @_presence_required = names
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
  alias_method :to_h, :args
  alias_method :to_hash, :args

  def initialize(hash = {})
    fail ArgumentError unless hash.respond_to?(:fetch)
    fail RequiredFieldNotPresent unless _required_args.map(&:to_sym).all? { |r| hash.keys.map(&:to_sym).include?(r) }
    fail PresenceRequired if _presence_required.map(&:to_sym).any? { |r| hash[r].nil? }
    @args = _defaults.merge(hash)
    args.each do |k, v|
      define_special_method(k, v)
      # define_singleton_method(k) { args.fetch(k) }
      # define_singleton_method("#{k}?") { true }
      # define_singleton_method("not_#{k}?") { false }
    end
  end

  def [](key)
    args[key]
  end

  def []=(key, value)
    set_attribute(key, value)
  end

  def method_missing(name, *args, &block)
    if ary = find_in_equivalents(name)
      _from_equivalents(ary)
    elsif name =~ /\A\w+=\z/
      value = args.first || block
      key = name.to_s.gsub('=', '').to_sym
      set_attribute(key, value)
    else
      case name.to_s
      when /\A\w+_not_provided\?\z/ then true
      when /\A\w+_provided\?\z/ then false
      end
    end
  end

  private

  def set_attribute(key, value)
    args[key] = value
    define_special_method(key, value)
  end

  def define_special_method(key, value)
    define_singleton_method(key) { args.fetch(key) }
    define_singleton_method("#{key}_provided?") { true }
    define_singleton_method("#{key}_not_provided?") { false }
  end

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

  def _presence_required
    self.class.instance_variable_get(:@_presence_required) || []
  end

  def _defaults
    self.class.instance_variable_get(:@_defaults) || {}
  end

  def _required_args
    self.class.instance_variable_get(:@_required) || []
  end
end
