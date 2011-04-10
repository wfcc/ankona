require 'spec_helper'

describe "marks/edit.html.erb" do
  before(:each) do
    @mark = assign(:mark, stub_model(Mark,
      :diagram => nil,
      :section => nil,
      :nummark => 1.5,
      :textmark => "MyString",
      :comment => "MyText"
    ))
  end

  it "renders the edit mark form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => mark_path(@mark), :method => "post" do
      assert_select "input#mark_diagram", :name => "mark[diagram]"
      assert_select "input#mark_section", :name => "mark[section]"
      assert_select "input#mark_nummark", :name => "mark[nummark]"
      assert_select "input#mark_textmark", :name => "mark[textmark]"
      assert_select "textarea#mark_comment", :name => "mark[comment]"
    end
  end
end
