class Contextuable
  VERSION = "0.2.0"

  class RequiredFieldNotPresent < ArgumentError; end
  class PresenceRequired < ArgumentError; end
  class WrongArgument < ArgumentError; end

  class << self
    def required(*names)
      @_required = names.map(&:to_sym)
    end

    def without_undefined_readers
      @_without_undefined_readers = true
      self
    end

    def ensure_presence(*names)
      @_presence_required = names.map(&:to_sym)
    end

    def aliases(*names)
      @_equivalents ||= []
      @_equivalents << names.map(&:to_sym)
    end

    def defaults(hash)
      @_defaults = hash
    end

    def permit(*names)
      @_permitted = names.map(&:to_sym)
    end
  end

  attr_reader :attrs
  alias_method :to_h, :attrs
  alias_method :to_hash, :attrs

  def initialize(hash = {})
    check_input_errors(hash)
    hash = hash.select{|k, v| _permitted.include?(k.to_sym) } if _only_permitted?
    @attrs = _defaults.merge(hash)
    attrs.each do |k, v|
      define_contextuable_method(k, v)
    end
  end

  def [](key)
    attrs[key]
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
      out = case name.to_s
            when /\A\w+_not_provided\?\z/ then { out: true }
            when /\A\w+_provided\?\z/ then { out: false }
            end
      return out[:out] if out
      _without_undefined_readers ? super : nil
    end
  end

  private

  def set_attribute(key, value)
    attrs[key] = value
    define_contextuable_method(key, value)
  end

  def define_contextuable_method(key, value)
    define_singleton_method(key) { attrs.fetch(key) }
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
      out = attrs[method.to_sym]
      break if out
    end
    out
  end

  def _only_permitted?
    _permitted.any?
  end

  def _permitted
    _get_config(:@_permitted) || []
  end

  def _equivalents
    _get_config(:@_equivalents) || []
  end

  def _presence_required
    _get_config(:@_presence_required) || []
  end

  def _without_undefined_readers
    _get_config(:@_without_undefined_readers)
  end

  def _defaults
    _get_config(:@_defaults) || {}
  end

  def _required_args
    _get_config(:@_required) || []
  end

  def _get_config(variable)
    self.class.instance_variable_get(variable)
  end

  def check_input_errors(hash)
    unless hash.class <= Hash
      fail WrongArgument, "[Contextuable ERROR]: `#{self.class}` expects to receive a `Hash` or and object having `Hash` as ancestor."
    end

    _required_args.map(&:to_sym).each do |r|
      unless hash.keys.map(&:to_sym).include?(r)
        fail RequiredFieldNotPresent, "[Contextuable ERROR]: `#{self.class}` expect to be initialized with `#{r}` as an attribute."
      end
    end

    _presence_required.map(&:to_sym).each do |r|
      if hash[r].nil?
        fail PresenceRequired, "[Contextuable ERROR]: `#{self.class}` expects to receive an attribute named `#{r}` not beeing `nil`"
      end
    end
  end
end
