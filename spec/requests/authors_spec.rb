require 'spec_helper'

describe "Authors" do
  describe "GET /authors" do
    it "displays authors" do
      #Author.create!(name: 'Xavier Zerro')
      get authors_path
      #response.status.should be(200)
      response.body.should include('Filter by name')
    end
  end
end
