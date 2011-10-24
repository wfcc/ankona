class SectionsController < ApplicationController

# ---------------
  def new
    competition = Competition.find(params[:competition_id])
    @section = competition.sections.create
    new_section_form = render_to_string layout: false
    new_section_form.gsub!("[#{@section.id}]", "[#{Time.now.to_i}]")
    render text: new_section_form, layout: false
  end

  # DELETE /parents/1/children/1 (AJAX)
# ---------------
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
# ---------------
  def index
    # select sections where a user is a judge or a director
    current_user_id = current_user.id
    @sections = Section \
      .joins{users} \
      .select('Distinct(SECTIONS.*)') \
      .where{(users.id == current_user_id) | (user_id == current_user_id)}
  end
  
# ---------------
  def judge
    @section = Section.find params[:id]
    @marks = @section.marks.select{|x| x.user_id == current_user.id}
  end
# ---------------
  def mark
  
    case
    when current_user.blank?
      render text: 'error: current user not found'
      return
    when params[:mark].present?
      mark = Mark.find params[:mark][:id]
      if mark.user != current_user
        render text: 'error: not permitted'
        return
      end
      mark[:nummark] = params[:nummark] if params[:nummark].present?
      mark[:comment] = params[:mark][:comment] if params[:mark][:comment].present?
    else
      mark = Mark.new \
        diagram_id: params[:diagram_id], 
        section_id: params[:section_id],
        user_id: current_user.id,
        nummark: params[:nummark],
        comment: params[:comment]
    end
    mark.save
      
    render nothing: true
  end
# ---------------
  def show
  
    @r = {}
    @section = Section.find params[:id]
    marks = Mark.joins(:section).where(section: {id: params[:id]}).all
    @k = marks.map{|x| x.user_id}.uniq

    marks.each do |mark|
      @r[mark.diagram_id] ||= [[], [], 0]
      @r[mark.diagram_id][0][@k.index(mark.user_id)] = mark.nummark
      @r[mark.diagram_id][1][@k.index(mark.user_id)] = mark.comment
      @r[mark.diagram_id][2] = @r[mark.diagram_id][0].inject{|s,x| s.to_f + x.to_f}
    end

  end
  

end
