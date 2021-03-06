require 'spec_helper'

describe CoursePagesController do
  before :each do
    @page = create :page, tag_list: 'test'
    Local.create
  end

  describe 'GET #show' do
    it 'responds successfully with an HTTP 200 status code' do
      get :show, id: @page.id
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :show template' do
      get :show, id: @page.id
      expect(response).to render_template :show
    end

    it 'assigns the list of modules for the current tab to @mods' do
      tab = @page.tabs.first
      tab.template = 1
      tab.save
      get :show, id: @page.id
      expect(assigns(:mods)).to match_array tab.sorted_nodes
    end

    it 'constructs lists of modules for the left and right columns' do
      tab = @page.tabs.first
      get :show, id: @page.id
      expect(assigns(:mods_left)).to match_array tab.left_nodes
      expect(assigns(:mods_right)).to match_array tab.right_nodes
    end

    it 'does not assign @mods in two-column layouts' do
      tab = @page.tabs.first
      get :show, id: @page.id
      expect(assigns(:mods)).to be_nil
    end

    it 'does not assign @mods_left or @mods_right in one-column layouts' do
      tab = @page.tabs.first
      tab.template = 1
      tab.save
      get :show, id: @page.id
      expect(assigns(:mods_left)).to be_empty
      expect(assigns(:mods_right)).to be_empty
    end
  end

  describe 'GET #index' do
    before :each do
      @page.published = true
      @page.save
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :published_pages template' do
      get :index
      expect(response).to render_template :index
    end

    it 'assigns a list of published pages to @pages' do
      get :index
      expect(assigns(:pages).empty?).to be_false
    end

    it 'assigns tags to @tags' do
      get :index
      expect(assigns(:tags)).to_not be_nil
      expect(assigns(:tags).empty?).to be_false
    end
  end

  describe 'GET #archived' do
    before :each do
      @page.archived = true
      @page.save
    end
    it 'responds successfully with an HTTP 200 status code' do
      get :archived
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :archived template' do
      get :archived
      expect(response).to render_template :archived
    end

    it 'assigns a list of published pages to @pages' do
      get :archived
      expect(assigns(:pages).empty?).to be_false
    end

    it 'assigns tags to @tags' do
      get :archived
      expect(assigns(:tags)).to_not be_nil
      expect(assigns(:tags).empty?).to be_false
    end
  end

  describe 'POST #archived' do
    before :each do
      @page.archived = true
      @page.save
    end

    it 'responds successfully with an HTTP 200 status code' do
      post :archived, subject: @page.subjects.first.id
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :archived template' do
      post :archived, subject: @page.subjects.first.id
      expect(response).to render_template :archived
    end

    it 'assigns a list of archived pages to @pages' do
      post :archived, subject: @page.subjects.first.id
      expect(assigns(:pages).empty?).to be_false
    end

    it 'assigns tags to @tags' do
      post :archived, subject: @page.subjects.first.id
      expect(assigns(:tags)).to_not be_nil
      expect(assigns(:tags).empty?).to be_false
    end
  end

  describe 'GET #tagged' do
    before :each do
      @page.published = true
      @page.save
    end

    it 'responds successfully with an HTTP 200 status code' do
      get :tagged, id: 'test'
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :tagged template' do
      get :tagged, id: 'test'
      expect(response).to render_template :tagged
    end

    it 'assigns a list of published pages to @pages' do
      get :tagged, id: 'test'
      expect(assigns(:pages).empty?).to be_false
    end

    it 'assigns tags to @tags' do
      get :tagged, id: 'test'
      expect(assigns(:tags)).to_not be_nil
      expect(assigns(:tags).empty?).to be_false
    end
  end
end
