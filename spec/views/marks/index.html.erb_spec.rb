require 'spec_helper'

describe "marks/index.html.erb" do
  before(:each) do
    assign(:marks, [
      stub_model(Mark,
        :diagram => nil,
        :section => nil,
        :nummark => 1.5,
        :textmark => "Textmark",
        :comment => "MyText"
      ),
      stub_model(Mark,
        :diagram => nil,
        :section => nil,
        :nummark => 1.5,
        :textmark => "Textmark",
        :comment => "MyText"
      )
    ])
  end

  it "renders a list of marks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Textmark".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
