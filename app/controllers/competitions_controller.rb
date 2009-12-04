class CompetitionsController < ApplicationController
  # GET /competitions
  # GET /competitions.xml
  def index
    @competitions = Competition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @competitions }
    end
  end

  # GET /competitions/1
  # GET /competitions/1.xml
  def show
    @competition = Competition.find(params[:id])
    @sections = @competition.sections

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @competition }
    end
  end

  # GET /competitions/new
  # GET /competitions/new.xml
  def new
    @competition = Competition.new

    1.times { @competition.sections.build }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @competition }
    end
  end

  # GET /competitions/1/edit
  def edit
    @competition = Competition.find(params[:id])
    render :action => 'new'
  end

  # POST /competitions
  # POST /competitions.xml
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

    respond_to do |format|

      params[:competition][:existing_section_attributes] ||= {}
      if @competition.update_attributes(params[:competition])
        flash[:notice] = 'Competition was successfully updated.'
        format.html { redirect_to(@competition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @competition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1
  # DELETE /competitions/1.xml
  def destroy
    @competition = Competition.find(params[:id])
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to(competitions_url) }
      format.xml  { head :ok }
    end
  end

  def judge
    redirect_to competitions_url
    if current_user
      i = Invite.new(
        :item => params[:competition][:section_ids],
        :email => params[:judge_email],
        :code => Random.alphanumeric(8),
        :accepted => false
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
