require 'spec_helper'

describe GuidesController do
  describe 'guest access' do
    describe 'POST #create' do
      it 'requires login' do
        post :create
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit' do
      it 'requires login' do
        get :edit
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'requires login' do
        get :new
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #show' do
      it 'requires login' do
        get :show
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #update' do
      it 'requires login' do
        put :update
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'author access' do
    before :each do
      @user = create :author
      session[:user_id] = @user.id
    end

    describe 'POST #create' do
      it 'creates a new page'
      it 'redirects to the :show view'
    end

    describe 'GET #index' do
      it 'renders the :index view' do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'individual guide' do
      before :each do
        @guide = create :guide
        @user.add_guide @guide
      end

      describe 'GET #edit' do
        it 'renders the :edit template' do
          get :edit, id: @guide.id
          expect(response).to render_template :edit
        end
      end

      describe 'GET #show' do
        it 'renders the :show view' do
          get :show, id: @guide.id
          expect(response).to render_template :show
        end
      end

      describe 'PUT #update' do
        it 'redirects to the :show view' do
          put :update, id: @guide.id, guide: { description: 'timmeh!' }
          expect(response).to redirect_to @guide
        end
      end
    end
  end
end
