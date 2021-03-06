require 'active_support/basic_object'

ActiveRecord::Base.class_eval do
  class WithoutCallbacks < ActiveSupport::BasicObject
    def initialize(target, types)
      @target = target
      @types  = types
    end

    def respond_to?(method, include_private = false)
      @target.respond_to?(method, include_private)
    end

    def method_missing(method, *args, &block)
      @target.skip_callbacks(*@types) do
        @target.send(method, *args, &block)
      end
    end
  end

  class << self
    def without_callbacks(*types)
      WithoutCallbacks.new(self, types)
    end

    def skip_callbacks(*types)
      deactivate_callbacks(*types)
      yield.tap do
        activate_callbacks(*types)
      end
    end

    def deactivate_callbacks(*types)
      # Apart from causing errors, this does not make any sense at all. Ever.
      # E.g. if the block fails (see skip_callbacks), the callbacks are never reactivated
      # And: If you have any domain knowledge in your callbacks, this will change behaviour.
      # So: This is wrong on (oh) so many levels. plz don't use it. KTHXBAI
      raise StronglyDeprecatedCodeError, 'this causes "NoMethodError: super called outside of method"'
      types = [:save, :create, :update, :destroy, :touch] if types.empty?
      types.each do |type|
        name = :"_run_#{type}_callbacks"
        alias_method(:"_deactivated_#{name}", name)
        define_method(name) { |&block| block.call }
      end
    end

    def activate_callbacks(*types)
      types = [:save, :create, :update, :destroy, :touch] if types.empty?
      types.each do |type|
        name = :"_run_#{type}_callbacks"
        alias_method(name, :"_deactivated_#{name}")
        undef_method(:"_deactivated_#{name}")
      end
    end
  end
end
