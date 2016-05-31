class Contextuable
  VERSION = "0.4.0"
  autoload :ClassMethods, 'contextuable/class_methods'
  autoload :InstanceMethods, 'contextuable/instance_methods'

  class RequiredFieldNotPresent < ArgumentError; end
  class PresenceRequired < ArgumentError; end
  class WrongArgument < ArgumentError; end

  def self.inherited(subclass)
    subclass.extend ClassMethods
    subclass.include InstanceMethods
  end

  attr_reader :attrs
  alias_method :to_h, :attrs
  alias_method :to_hash, :attrs

  def initialize(hash = {})
    unless hash.class <= Hash
      fail WrongArgument, "[Contextuable ERROR]: `#{self.class}` expects to receive a `Hash` or and object having `Hash` as ancestor."
    end
    @attrs = hash
    @attrs.each do |k, v|
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
    if name =~ /\A\w+=\z/
      set_attribute_macro(name, *args, &block)
    elsif out = provided_macro(name)
      out[:out]
    else
      super
    end
  end

  private

  def set_attribute_macro(name, *args, &block)
    value = args.first || block
    key = name.to_s.gsub('=', '').to_sym
    set_attribute(key, value)
  end

  def provided_macro(name)
    case name.to_s
    when /\A\w+_not_provided\?\z/ then { out: true }
    when /\A\w+_provided\?\z/ then { out: false }
    end
  end

  def set_attribute(key, value)
    attrs[key] = value
    define_contextuable_method(key, value)
  end

  def define_contextuable_method(key, value)
    define_singleton_method(key) { attrs.fetch(key) }
    define_singleton_method("#{key}_provided?") { true }
    define_singleton_method("#{key}_not_provided?") { false }
  end
end
