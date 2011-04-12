class SectionsController < ApplicationController
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
  
  def index
    @sections = Section.joins(:users).where(users: {id: current_user.id})
  end
  
  def judge
    @section = Section.find params[:id]
    @marks = @section.marks.select{|x| x.user_id == current_user.id}
  end

  def mark
    case
    when current_user.blank?
      render text: 'error'
      return
    when params[:mid].present?
      mark = Mark.find params[:mid]
      mark[:nummark] = params[:nummark] if mark.user == current_user
    else
      mark = Mark.new \
        diagram_id: params[:diagram_id], 
        section_id: params[:section_id],
        user_id: current_user.id,
        nummark: params[:nummark]
    end
    mark.save
      
    render text: mark.id
  end

end
