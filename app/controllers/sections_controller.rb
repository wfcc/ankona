class SectionsController < AuthorizedController

# ---------------
  def new
    competition = Competition.find(params[:competition_id])
    @section = competition.sections.create
    new_section_form = render_to_string layout: false
    new_section_form.gsub!("[#{@section.id}]", "[#{Time.now.to_i}]")
    render text: new_section_form, layout: false
  end # ---------------
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
  end # ---------------
  def index
    # select sections where a user is a judge or a director
    current_user_id = current_user.id
    @sections =
    (Section \
      .joins{users} \
      .select('Distinct(SECTIONS.*)') \
      .where{(users.id == current_user_id)} + \
    Section \
      .joins{user}.where{user.id == current_user_id}).sort.uniq
      
  end # ---------------
  def judge

    if params[:q].blank?
      params[:q] = {}
      params[:q][:sections_id_eq] = params[:id]
    end

    @q = Diagram.search(params[:q])
    @diagrams = @q.result(distinct: true).paginate page: params[:page], per_page: 20
      
    @section = Section.find params[:q][:sections_id_eq]
    #@diagrams = @section.diagrams.paginate page: params[:page], per_page: 10
    @marks = @section.marks.select{|x| x.user_id == current_user.id}
  end # ---------------
  def mark
  
    render nothing: true

    case
    when current_user.blank?
      logger.error "User required to mark"
      return
    when params[:id].blank?
      logger.error "Blank mark id"
      return
    end

    m = Mark.find_by_id params[:mark][:id]
    case
    when (m.present? and m.user != current_user)
      logger.error "User #{current_user.id} not permitted to mark #{m.id}"
      return
    end

    if m.present?
      m.update_attributes params[:mark]
    else
      m = Mark.new params[:mark]
      m.user = current_user
    end
    m.save
      
  end # ---------------
  def show
  
    @r = {}
    @section = Section.find params[:id]
    marks = @section.marks.select{|m|m.diagram_id.present?}
    @k = marks.map{|x| x.user_id}.uniq

    marks.each do |mark|
      @r[mark.diagram_id] ||= [[], [], 0, Diagram.find_by_id(mark.diagram_id).label]
      @r[mark.diagram_id][0][@k.index(mark.user_id)] = mark.nummark
      @r[mark.diagram_id][1][@k.index(mark.user_id)] = mark.comment
      @r[mark.diagram_id][2] = @r[mark.diagram_id][0].inject{|s,x| s.to_f + x.to_f}
    end

  end # ---------------
  def textual
    show
  end # ---------------
  

end
