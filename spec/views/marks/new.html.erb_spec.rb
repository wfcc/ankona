require 'spec_helper'

describe "marks/new.html.erb" do
  before(:each) do
    assign(:mark, stub_model(Mark,
      :diagram => nil,
      :section => nil,
      :nummark => 1.5,
      :textmark => "MyString",
      :comment => "MyText"
    ).as_new_record)
  end

  it "renders new mark form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => marks_path, :method => "post" do
      assert_select "input#mark_diagram", :name => "mark[diagram]"
      assert_select "input#mark_section", :name => "mark[section]"
      assert_select "input#mark_nummark", :name => "mark[nummark]"
      assert_select "input#mark_textmark", :name => "mark[textmark]"
      assert_select "textarea#mark_comment", :name => "mark[comment]"
    end
  end
end
