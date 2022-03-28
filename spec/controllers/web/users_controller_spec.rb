# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::UsersController, :type => :controller do
  render_views

  before do
    sign_in user
  end

  describe '#index' do
    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      it 'should render index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#new' do
    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      it 'should render index template' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        get :new
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#create' do
    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      context 'with valid params' do
        let(:params) do
          {
            user: {
              email: 'test@test.com',
              password: '12345678',
              role: "manager",
              city: 'london'
            }
          }
        end

        it 'shouild redirect to users list' do
          post :create, params: params
          expect(response).to redirect_to(users_path)
        end

        it 'shouild send notice' do
          post :create, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it 'should create user' do
          expect { post :create, params: params }.to(
            change { User.count }.by(1)
          )
        end

        context 'user already exists' do
          before { User.create(params[:user]) }

          it 'shouild redirect to current page' do
            post :create, params: params
            expect(response).to redirect_to(new_user_path)
          end

          it 'shouild send alert with error' do
            post :create, params: params
            expect(flash[:alert]).not_to be_empty
          end

          it 'shouldn\'t create user' do
            expect { post :create, params: params }.not_to(
              change { User.count }
            )
          end
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            user: {
              email: 'test@test.com',
              password: '12345678'
            }
          }
        end

        it 'shouild redirect to current page' do
          post :create, params: params
          expect(response).to redirect_to(new_user_path)
        end

        it 'shouild send alert with error' do
          post :create, params: params
          expect(flash[:alert]).not_to be_empty
        end

        it 'shouldn\'t create user' do
          expect { post :create, params: params }.not_to(
            change { User.count }
          )
        end
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        post :create
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#edit' do
    let(:other_user) { create(:user, role: 'manager') }
    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      it 'should render index template' do
        get :edit, params: { id: other_user.id }
        expect(response).to render_template(:edit)
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        get :edit, params: { id: other_user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    let(:other_user) { create(:user, role: 'admin', email: 'admin@admin.com', city: 'liverpool') }

    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      context 'with valid params' do
        let(:params) do
          {
            user: {
              email: 'test@test.com',
              password: '',
              role: "manager",
              city: 'london'
            },
            id: other_user.id
          }
        end

        it 'shouild redirect to users list' do
          post :update, params: params
          expect(response).to redirect_to(users_path)
        end

        it 'shouild send notice' do
          post :update, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it 'should update user' do
          post :update, params: params
          other_user.reload
          expect(other_user.email).to eq params[:user][:email]
          expect(other_user.role).to eq params[:user][:role]
          expect(other_user.city).to eq params[:user][:city]
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            user: {
              email: 'test@test.com',
              password: '12'
            },
            id: other_user.id
          }
        end

        it 'shouild redirect to current page' do
          post :update, params: params
          expect(response).to redirect_to(edit_user_path)
        end

        it 'shouild send alert with error' do
          post :update, params: params
          expect(flash[:alert]).not_to be_empty
        end

        it 'shouldn\'t update user' do
          post :update, params: params
          old_email = other_user.email
          other_user.reload
          expect(other_user.email).to eq old_email
        end
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        post :update, params: { id: other_user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#destroy' do
    let(:other_user) { create(:user, role: 'admin', email: 'admin@admin.com', city: 'liverpool') }

    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      context 'with valid params' do
        let(:params) do
          {
            id: other_user.id
          }
        end

        it 'shouild redirect to users list' do
          post :destroy, params: params
          expect(response).to redirect_to(users_path)
        end

        it 'shouild send notice' do
          post :destroy, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it 'should destroy user' do
          post :destroy, params: params
          expect(User.where(email: other_user.email, deleted: true).exists?).to be_falsy
        end
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager') }
      
      it 'should return forbidden code' do
        post :destroy, params: { id: other_user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
