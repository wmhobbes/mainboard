class Module
  def memoized(method_name)
    original_method = "unmemoized_#{method_name}_#{Time.now.to_i}"
    alias_method original_method, method_name
    module_eval(<<-EVAL, __FILE__, __LINE__)
      def #{method_name}(reload = false, *args, &block)
        expirable_memoize(reload) do
          send(:#{original_method}, *args, &block)
        end
      end
    EVAL
  end

  def constant(name, value)
    unless const_defined?(name)
      const_set(name, value)
      module_eval(<<-EVAL, __FILE__, __LINE__)
        def self.#{name.to_s.downcase}
          #{name.to_s}
        end
      EVAL
    end
  end

end


module Kernel #:nodoc:

  # This is similar to +Module#const_get+ but is accessible at all levels,
  # and, unlike +const_get+, can handle module hierarchy.
  #
  #   constantize("Fixnum")                  # -> Fixnum
  #   constantize(:Fixnum)                   # -> Fixnum
  #
  #   constantize("Process::Sys")            # -> Process::Sys
  #   constantize("Regexp::MULTILINE")       # -> 4
  #
  #   require 'test/unit'
  #   Test.constantize("Unit::Assertions")   # -> Test::Unit::Assertions
  #   Test.constantize("::Test::Unit")       # -> Test::Unit
  #
  # CREDIT: Trans

  def constantize(const)
    const = const.to_s.dup
    base = const.sub!(/^::/, '') ? Object : ( self.kind_of?(Module) ? self : self.class )
    const.split(/::/).inject(base){ |mod, name| mod.const_get(name) }
  end

end
