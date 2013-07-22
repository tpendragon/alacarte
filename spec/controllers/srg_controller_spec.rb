require 'spec_helper'

describe SrgController do
  before :each do
    @guide = create :guide
    Local.create
  end

  describe 'GET #show' do
    it 'responds successfully with an HTTP 200 status code' do
      get :show, id: @guide.id
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    it 'renders the :show template' do
      get :show, id: @guide.id
      expect(response).to render_template :show
    end

    it 'assigns the list of modules for the current tab to @mods' do
      tab = @guide.tabs.first
      tab.template = 1
      tab.save
      get :show, id: @guide.id
      expect(assigns(:mods)).to match_array tab.sorted_modules
    end

    it 'constructs lists of modules for the left and right columns' do
      tab = @guide.tabs.first
      get :show, id: @guide.id
      expect(assigns(:mods_left)).to match_array tab.left_modules
      expect(assigns(:mods_right)).to match_array tab.right_modules
    end

    it 'does not assign @mods in two-column layouts' do
      tab = @guide.tabs.first
      get :show, id: @guide.id
      expect(assigns(:mods)).to be_nil
    end

    it 'does not assign @mods_left or @mods_right in one-column layouts' do
      tab = @guide.tabs.first
      tab.template = 1
      tab.save
      get :show, id: @guide.id
      expect(assigns(:mods_left)).to be_nil
      expect(assigns(:mods_right)).to be_nil
    end
  end
end