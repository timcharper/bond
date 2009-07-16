# Represents a completion mission specified by :object in Bond.complete. Unlike other missions, this
# one needs to both match the mission condition and have the current object being completed have
# an ancestor specified by :object.
class Bond::Missions::ObjectMission < Bond::Mission
  #:stopdoc:
  def initialize(options={})
    @object_condition = options.delete(:object)
    @object_condition = /^#{Regexp.quote(@object_condition.to_s)}$/ unless @object_condition.is_a?(Regexp)
    options[:on] = /^((\.?[^.]+)+)\.([^.]*)$/
    @eval_binding = options[:eval_binding] || default_eval_binding
    super
  end

  def handle_valid_match(input)
    match = super
    if match && eval_object(match) && (match = @evaled_object.class.ancestors.any? {|e| e.to_s =~ @object_condition })
      @list_prefix = @matched[1] + "."
      @input = @matched[3]
      @input.instance_variable_set("@object", @evaled_object)
      @input.instance_eval("def self.object; @object ; end")
      @action ||= lambda {|e| default_action(e.object) }
    else
      match = false
    end
    match
  end

  def eval_object(match)
    @matched = match
    @evaled_object = begin eval("#{match[1]}", @eval_binding); rescue Exception; nil end
  end

  def default_action(obj)
    obj.methods - OPERATORS
  end

  def default_eval_binding
    Object.const_defined?(:IRB) ? IRB.CurrentContext.workspace.binding : ::TOPLEVEL_BINDING
  end
  #:startdoc:
end