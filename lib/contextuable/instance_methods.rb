class Contextuable
  module InstanceMethods
    def initialize(hash = {})
      check_input_errors(hash)
      hash = hash.select{|k, v| _permitted.include?(k.to_sym) } if _only_permitted?
      @attrs = _defaults.merge(hash)
      attrs.each do |k, v|
        define_contextuable_method(k, v)
      end
    end

    def method_missing(name, *args, &block)
      if ary = find_in_equivalents(name)
        _from_equivalents(ary)
      elsif name =~ /\A\w+=\z/
        set_attribute_macro(name, *args, &block)
      else
        out = provided_macro(name)
        return out[:out] if out
        if _no_method_error
          raise NoMethodError, "Method not found for #{self.class}: `#{name}`"
        end
      end
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
      _get_config[:permitted] || []
    end

    def _equivalents
      _get_config[:equivalents] || []
    end

    def _presence_required
      _get_config[:presence_required] || []
    end

    def _no_method_error
      !_get_config[:no_method_error] == false
    end

    def _defaults
      _get_config[:defaults] || {}
    end

    def _required_args
      _get_config[:required] || []
    end

    def _get_config
      self.class.settings
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
end
