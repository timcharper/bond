# A mission which completes an object's methods. For this mission to match,
# the condition must match and the current object must have an ancestor that matches :object.
# Note: To access to the current object being completed on within an action, use the input's
# object attribute.
#
# ==== Bond.complete Options:
# [*:object*] String representing a module/class of object whose methods are completed.
# [*:action*] If an action is not specified, the default action is to complete an object's
#             non-operator methods.
#
# ===== Example:
#   Bond.complete(:object=>ActiveRecord::Base) {|input| input.object.class.instance_methods(false) }
class Bond::ObjectMission < Bond::Mission
  #:stopdoc:
  OBJECTS = %w<\S+> + Bond::Mission::OBJECTS
  CONDITION = '(OBJECTS)\.(\w*(?:\?|!)?)$'
  def initialize(options={})
    @object_condition = /^#{options[:object]}$/
    options[:on] ||= Regexp.new condition_with_objects
    super
  end

  def unique_id
    "#{@object_condition.inspect}+#{@on.inspect}"
  end

  def do_match(input)
    super && eval_object(@matched[1]) && @evaled_object.class.respond_to?(:ancestors) &&
      @evaled_object.class.ancestors.any? {|e| e.to_s =~ @object_condition }
  end

  def after_match(input)
    @completion_prefix = @matched[1] + "."
    @action ||= lambda {|e| default_action(e.object) }
    create_input @matched[2], :object=>@evaled_object
  end

  def default_action(obj)
    obj.methods.map {|e| e.to_s} - OPERATORS
  end

  def match_message
    "Matches completion for object with ancestor matching #{@object_condition.inspect}."
  end
  #:startdoc:
end