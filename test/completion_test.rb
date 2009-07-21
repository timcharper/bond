require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::CompletionTest < Test::Unit::TestCase
  before(:all) { Bond.agent.reset; Bond.debrief(:readline_plugin=>valid_readline_plugin); require 'bond/completion' }

  test "completes object methods anywhere" do
    matches = tabtab("blah :man.")
    assert matches.size > 0
    assert matches.all? {|e| e=~ /^:man/}
  end

  test "completes global variables anywhere" do
    matches = tabtab("blah $-")
    assert matches.size > 0
    assert matches.all? {|e| e=~ /^\$-/}
  end

  test "completes absolute constants anywhere" do
    tabtab("blah ::Arr").should == ["::Array"]
  end

  test "completes nested classes anywhere" do
    tabtab("blah IRB::In").should == ["IRB::InputCompletor"]
  end

  test "completes symbols anywhere" do
    Symbol.expects(:all_symbols).returns([:mah])
    assert tabtab("blah :m").size > 0
  end
end