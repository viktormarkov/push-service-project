# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::PushMessagesController, :type => :controller do
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
      
      it 'should render index template' do
        get :index
        expect(response).to render_template(:index)
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
      
      it 'should render index template' do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#show' do
    let(:push_message) { create(:push_message, city: 'london') }

    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }

      it 'should render index template' do
        get :show, params: { id: push_message.id }
        expect(response).to render_template(:show)
      end
    end

    context 'user is manager' do
      let(:user) { create(:user, role: 'manager', city: 'london') }
      
      it 'should render index template' do
        get :show, params: { id: push_message.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe '#create' do
    let(:expo_response) { FakeResponse.new }

    before do
      allow_any_instance_of(HttpClient).to(receive(:post).and_return(expo_response))
      allow(expo_response).to receive(:status).and_return(expo_status_code)
      allow(expo_response).to receive(:body).and_return(expo_body)
    end

    context 'user is admin' do
      let(:user) { create(:user, role: 'admin') }
      let!(:token_london) { create(:device_token, city: 'london') }
      let!(:token_liverpool) { create(:device_token, city: 'liverpool') }

      context 'with valid params' do
        let(:expo_status_code) { 200 }
        let(:expo_body) do
          [
            { status: 'ok' },
            { status: 'ok'},
            { status: 'ok' }
          ].to_json
        end

        let(:params) do
          {
            push_message: {
              title: 'title',
              body: 'body',
              city: 'london'
            }
          }
        end

        it 'shouild redirect to users list' do
          post :create, params: params
          expect(response).to redirect_to(push_message_path(PushMessage.last.id))
        end

        it 'shouild send notice' do
          post :create, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it 'should create push message' do
          expect { post :create, params: params }.to(
            change { PushMessage.count }.by(1)
          )
        end

        it 'push message should be with success status' do
          post :create, params: params 
          expect(PushMessage.last.successfull?).to be_truthy
        end

        it 'push message should be with values from params' do
          post :create, params: params 
          message = PushMessage.last
          expect(message.title).to eq params[:push_message][:title]
          expect(message.body).to eq params[:push_message][:body]
          expect(message.city).to eq params[:push_message][:city]
          expect(message.creator_id).to eq user.id
        end

        it 'should create push result' do
          expect { post :create, params: params }.to(
            change { PushResult.count }.by(1)
          )
        end

        it 'push result should be with success status' do
          post :create, params: params 
          expect(PushResult.last.successfull?).to be_truthy
        end

        it 'push result should be with right values' do
          post :create, params: params 
          result = PushResult.last
          expect(result.push_message_id).to eq PushMessage.last.id
          expect(result.recepient_token_ids).to eq [token_london.id]
          expect(result.status_tickets).to eq JSON.parse(expo_body)
        end

        context 'expo errors' do
          let(:expo_status_code) { 400 }
          let(:expo_body) { 'wrong project!' }

          it 'shouild redirect to users list' do
            post :create, params: params
            expect(response).to redirect_to(push_message_path(PushMessage.last.id))
          end
  
          it 'shouild send alert' do
            post :create, params: params
            expect(flash[:alert]).not_to be_empty
          end
  
          it 'should create push message' do
            expect { post :create, params: params }.to(
              change { PushMessage.count }.by(1)
            )
          end

          it 'push message should be with failed status' do
            post :create, params: params 
            expect(PushMessage.last.failed?).to be_truthy
          end
  
          it 'push message should be with values from params' do
            post :create, params: params 
            message = PushMessage.last
            expect(message.title).to eq params[:push_message][:title]
            expect(message.body).to eq params[:push_message][:body]
            expect(message.city).to eq params[:push_message][:city]
            expect(message.creator_id).to eq user.id
          end

          it 'should create push result' do
            expect { post :create, params: params }.to(
              change { PushResult.count }.by(1)
            )
          end
  
          it 'push result should be with success status' do
            post :create, params: params 
            expect(PushResult.last.failed?).to be_truthy
          end
  
          it 'push result should be with right values' do
            post :create, params: params 
            result = PushResult.last
            expect(result.push_message_id).to eq PushMessage.last.id
            expect(result.recepient_token_ids).to eq [token_london.id]
            expect(result.error).to eq expo_status_code.to_s + ': ' + expo_body
          end
        end
      end

      context 'with invalid params' do
        let(:expo_status_code) { 200 }
        let(:expo_body) { {} }

        let(:params) do
          {
            push_message: {
              title: 'title',
              city: 'london'
            }
          }
        end

        it 'shouild redirect to current page' do
          post :create, params: params
          expect(response).to redirect_to(new_push_message_path)
        end

        it 'shouild send alert with error' do
          post :create, params: params
          expect(flash[:alert]).not_to be_empty
        end

        it 'shouldn\'t create push message' do
          expect { post :create, params: params }.not_to(
            change { PushMessage.count }
          )
        end
      end
    end
    context 'user is admin' do
      let(:user) { create(:user, role: 'manager', city: 'london') }
      let!(:token_london) { create(:device_token, city: 'london') }
      let!(:token_liverpool) { create(:device_token, city: 'liverpool') }

      context 'with valid params' do
        let(:expo_status_code) { 200 }
        let(:expo_body) do
          [
            { status: 'ok' },
            { status: 'ok'},
            { status: 'ok' }
          ].to_json
        end

        let(:params) do
          {
            push_message: {
              title: 'title',
              body: 'body',
              city: 'london'
            }
          }
        end

        it 'shouild redirect to users list' do
          post :create, params: params
          expect(response).to redirect_to(push_message_path(PushMessage.last.id))
        end

        it 'shouild send notice' do
          post :create, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it 'should create push message' do
          expect { post :create, params: params }.to(
            change { PushMessage.count }.by(1)
          )
        end

        it 'push message should be with success status' do
          post :create, params: params 
          expect(PushMessage.last.successfull?).to be_truthy
        end

        it 'push message should be with values from params' do
          post :create, params: params 
          message = PushMessage.last
          expect(message.title).to eq params[:push_message][:title]
          expect(message.body).to eq params[:push_message][:body]
          expect(message.city).to eq params[:push_message][:city]
          expect(message.creator_id).to eq user.id
        end

        it 'should create push result' do
          expect { post :create, params: params }.to(
            change { PushResult.count }.by(1)
          )
        end

        it 'push result should be with success status' do
          post :create, params: params 
          expect(PushResult.last.successfull?).to be_truthy
        end

        it 'push result should be with right values' do
          post :create, params: params 
          result = PushResult.last
          expect(result.push_message_id).to eq PushMessage.last.id
          expect(result.recepient_token_ids).to eq [token_london.id]
          expect(result.status_tickets).to eq JSON.parse(expo_body)
        end
      end
    end
  end
end