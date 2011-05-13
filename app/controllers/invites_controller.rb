# coding: utf-8
class InvitesController < ApplicationController

  before_filter :require_user, :except => :decline

  # GET /invites
  # GET /invites.xml
  def index
    @invites = Invite.all
  end

  # GET /invites/1
  # GET /invites/1.xml
  def show
    @invite = Invite.find(params[:id])
  end

  # GET /invites/new
  # GET /invites/new.xml
  def new
    @invite = Invite.new
  end

  # GET /invites/1/edit
  def edit
    @invite = Invite.find(params[:id])
  end
  #------------------------------------------------
  def react
    @invite = Invite.where(code: params[:code], accepted: false).first
    case
    when (not @invite)
      flash[:error] = 'This invitation code is not found.'
    when (params[:accepted] and not current_user)
      flash[:error] = 'Please register and/or log in, then follow this link.'
      redirect_to url_for(:controller => :user_sessions, :action => :new)
    else
      sect = Section.find @invite.item
      @name =  sect.competition.name
      @name = "section “#{sect.name}” in #{@name}" if sect.name

      if sect.competition.user == current_user
        flash[:error] = "You are director of “#{sect.competition.name}”, you can't be its judge!"
      elsif params[:accepted]
        flash[:notice] = "You have accepted to jugde #{@name}."
        Notifier.deliver_acceptance_to_judge current_user, @name, sect.competition
        @invite.accepted = true
        sect.users << current_user
      else
        flash[:error] = "You have declined to jugde #{@name}."
        Notifier.deliver_refusal_to_judge @invite.email, @name, sect.competition
        @invite.accepted = false
      end
      @invite.save
      redirect_to competition_path sect.competition
    end
  end
  #------------------------------------------------

  # POST /invites
  # POST /invites.xml
  def create
    @invite = Invite.new(params[:invite])

    if @invite.save
      flash[:notice] = 'Invite was successfully created.'
      redirect_to(@invite)
    else
      flash[:error] = 'Error creating invite.'
      render :action => "new"
    end
  end

  # PUT /invites/1
  # PUT /invites/1.xml
  def update
    @invite = Invite.find(params[:id])

    respond_to do |format|
      if @invite.update_attributes(params[:invite])
        flash[:notice] = 'Invite was successfully updated.'
        format.html { redirect_to(@invite) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invites/1
  # DELETE /invites/1.xml
  def destroy
    @invite = Invite.find(params[:id])
    @invite.destroy

    respond_to do |format|
      format.html { redirect_to(invites_url) }
      format.xml  { head :ok }
    end
  end
end
