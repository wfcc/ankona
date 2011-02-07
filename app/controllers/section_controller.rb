class SectionController < ApplicationController
  def new
    competition = Competition.find(params[:competition_id])
    @section = competition.sections.create
    new_section_form = render_to_string layout: false
    new_section_form.gsub!("[#{@section.id}]", "[#{Time.now.to_i}]")
    render text: new_section_form, layout: false
  end

  # DELETE /parents/1/children/1 (AJAX)
  def destroy
    competition = Competition.find(params[:competition_id])
    unless competition.sections.exists?(params[:id])
      render text: { success: false, msg: 'the section was not found.' }.to_json and return
    end
    if competition.sections.destroy(params[:id]) 
      #// Rails < 2.3.5, if parent.children.destroy(Child.find(params[:id]))
      render text: { success: true }.to_json
    else
      render text: { success: false, msg: 'something unexpected happened.' }.to_json
    end
  end

end
