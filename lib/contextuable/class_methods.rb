class Contextuable
  module ClassMethods

    def settings
      @settings ||= {}
    end

    def required(*names)
      settings[:required] = names.map(&:to_sym)
    end

    def no_method_error(input = true)
      settings[:no_method_error] = input
    end

    def open_struct_behavior(input = true)
      settings[:no_method_error] = !input
    end

    def ensure_presence(*names)
      settings[:presence_required] = names.map(&:to_sym)
    end

    def aliases(*names)
      settings[:equivalents] ||= []
      settings[:equivalents] << names.map(&:to_sym)
    end

    def defaults(hash)
      settings[:defaults] = hash
    end

    def permit(*names)
      settings[:permitted] = names.map(&:to_sym)
    end
  end
end
