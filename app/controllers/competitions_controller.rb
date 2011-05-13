class CompetitionsController < AuthorizedController

  #before_filter :require_user, :only => [:destroy, :edit]
  #before_filter :require_director, :only => [:destroy, :edit]

  def index
    @competitions = Competition.all
  end

  def show
    @competition = Competition.find(params[:id])
    @sections = @competition.sections
  end

  def new
    @competition = Competition.new
    1.times { @competition.sections.build }
  end

  def edit
    @competition = Competition.find(params[:id])
    render :action => 'new'
  end

  def create
    @competition = Competition.new(params[:competition])
    @competition.user = current_user

    respond_to do |format|
      if @competition.save
        flash[:notice] = 'Competition was successfully created.'
        format.html { redirect_to(@competition) }
        format.xml  { render :xml => @competition, :status => :created, :location => @competition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @competition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /competitions/1
  # PUT /competitions/1.xml
  def update
    @competition = Competition.find(params[:id])


    params[:competition][:sections_attributes].each_value do |v|
      #v['name'] = v['name'].upcase
      v['_destroy'] = 1 if v['name'].blank?
    end
    
      
    if @competition.update_attributes(params[:competition])
      flash[:notice] = 'Competition was successfully updated.'
      render :show
    else
      render action: :new
    end
  end

  def destroy
    @competition = Competition.find(params[:id])
    @competition.destroy

    redirect_to(competitions_url)
  end

  def judge
    redirect_to competitions_url
    if current_user
      i = Invite.new(
        item: params[:competition][:section_ids],
        email: params[:judge_email],
        code: SecureRandom.hex(8),
        accepted: false
      )
      i.save
      section = Section.find i.item
      Notifier.deliver_invitation_to_judge current_user.name, section, i
      flash[:notice] = "Your invitation has been mailed to #{params[:judge_email]}."
    else
      flash[:error] = 'You have to be logged in to invite.'
    end
  end
end
