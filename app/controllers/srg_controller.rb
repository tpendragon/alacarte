class SrgController < ApplicationController
  skip_before_filter :authorize
  layout 'template'

  def show
    @guide = Guide.includes(:users, {:masters => :guides}, :subjects, :resource, :tags).find(params[:id])
    @tabs = @guide.tabs
    @tab = params[:tab] ? @tabs.select{|t| t.id == params[:tab].to_i}.first : @tabs.first
    if @tab and @tab.template == 2
      @style ='width:290px; height:250px;'
      @mods_left  = @tab.left_modules
      @mods_right = @tab.right_modules
    elsif @tab
      @style ='width:425px; height:350px;'
      @mods = @tab.sorted_modules
      @mods_left, @mods_right = [], []
    else
      render_404
    end
    @title= @guide.guide_name + " |  "+ @local.guide_page_title
    @meta_keywords = @guide.tag_list
    @meta_description = @guide.description
    @owner = @guide.users.select{|u| u.name == @guide.created_by}.first
    @updated = @guide.updated_at.to_formatted_s(:short)
    @mod = @guide.resource.mod if @guide.resource
    @related_guides = @guide.related_guides
    @related_pages = @guide.related_pages
  end

  def published_guides
    @meta_keywords = @local.guide_page_title + ", Research Guides, Research Topics, Library Help Guides"
    @meta_description = @local.guide_page_title + ". Library Help Guides for Subject Research. "
    @title = @local.guide_page_title
    @guides = Guide.published_guides
    @masters = Master.where("value <> ? AND value <> ?", "Tutorial", "Internal").order("value").includes(:guides)
    @tags = Guide.where(:published => true).tag_counts_on(:tags, :start_at => Time.now.prev_year, :order => 'taggings.created_at desc').limit 100
  end

  def internal_guides
    @from = 'internal'
    @meta_keywords = "Internal, Tutorials, Library Guides"
    @meta_description = @local.tutorial_page_title
    @title = "Internal Guides & Tutorials"
    @tutorials = Tutorial.get_internal_tutorials
    @subjects = @tutorials.collect{|t| t.subject}.flatten.uniq.compact
    @tutorials = @tutorials.select{|t| t.subject.blank?}
    @tags = Tutorial.where(:published => true).tag_counts_on(:tags, :start_at => Time.now.prev_year, :order => 'taggings.created_at desc').limit 100
    master = Master.find_by_value("Internal")
    @guides = master.published_guides if master
    render "ort/published_tutorials"
  end

  def tagged
    @tag = params[:id]
    @guides = Guide.tagged_with(@tag).where published: true
  end

  def feed
    @guide = Guide.find(params[:id])
    @mods = @guide.recent_modules
    @guide_url = url_for :controller => 'srg', :action => 'index', :id => @guide
    @guide_title = @guide.guide_name
    @guide_description = @guide.description
    author = @guide.users.select{|u| u.name == @guide.created_by}.first
    @author_email = author.email + " ("+author.name+")" if author
    response.headers['Content-Type'] = 'application/rss+xml'
    respond_to do |format|
      format.xml {render  :layout => false}
    end
  end
end
