# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DeviceTokensController, :type => :controller do
  describe '#create' do
    context 'with valid params' do
      let(:params) do
        { 
          api_key: Rails.application.credentials.api_key!,
          device_token: { 
            value: 'token123', city: 'london' 
          }
        }
      end

      context 'with uniq value' do
        it 'should be successful' do
          post :create, params: params
          
          expect(response).to have_http_status(:created)
        end
        
        it 'should save new token' do
          expect { post :create, params: params }.to(
            change { DeviceToken.count }.by(1)
          )
        end
      end

      context 'with duplicated value' do
        before do
          DeviceToken.create(params[:device_token])
        end

        it 'should be successful' do
          post :create, params: params
          expect(response).to have_http_status(:created)
        end

        it 'shouldn\'t save new token' do
          expect { post :create, params: params }.not_to(
            change { DeviceToken.count }
          )
        end
      end
    end

    context 'with invalid params' do
      let(:params) do
        { 
          api_key: Rails.application.credentials.api_key!,
          device_token: {
            value: 'token123'
          }
        }
      end

      it 'shouldn\'t be successful' do
        post :create, params: params
        expect(response).to have_http_status(:bad_request)
      end

      it 'shouldn\'t save new token' do
        expect { post :create, params: params }.not_to(
          change { DeviceToken.count }
        )
      end
    end

    context 'without api_key' do
      let(:params) do
        { 
          device_token: { 
            value: 'token123', city: 'london' 
          }
        }
      end

      it 'should return unauthorized code' do
        post :create, params: params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'shouldn\'t create token' do
        expect { post :create, params: params }.not_to(
          change { DeviceToken.count }
        )
      end
    end
  end
end
