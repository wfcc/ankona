
class FaqsController < ApplicationController

  before_filter :require_admin, :except => :show
  caches_page :show

  # GET /faqs
  def index
    @faqs = Faq.all
  end

  # GET /faqs/1
  def show
    @faq = Faq.find(params[:id])
  end

  # GET /faqs/new
  def new
    @faq = Faq.new
  end

  # GET /faqs/1/edit
  def edit
    @faq = Faq.find(params[:id])
  end

  # POST /faqs
  def create
    @faq = Faq.new(params[:faq])

    respond_to do |format|
      if @faq.save
        flash[:notice] = 'Faq was successfully created.'
        format.html { redirect_to(@faq) }
        format.xml  { render :xml => @faq, :status => :created, :location => @faq }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @faq.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /faqs/1
  # PUT /faqs/1.xml
  def update
    @faq = Faq.find(params[:id])

    respond_to do |format|
      if @faq.update_attributes(params[:faq])
        flash[:notice] = 'Faq was successfully updated.'
        format.html { redirect_to(@faq) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @faq.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /faqs/1
  # DELETE /faqs/1.xml
  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy

    respond_to do |format|
      format.html { redirect_to(faqs_url) }
      format.xml  { head :ok }
    end
  end
end
