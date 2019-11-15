require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'Yandex' do
    let(:oauth_data) { { 'provider' => 'yandex', 'uid' => 123 } }

    it 'finds user from oauth data' do
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth_data)
      expect(User).to receive(:find_for_oauth).with(oauth_data)
      get :yandex
    end

    context 'user exist' do
      let!(:user) { create :user }

      before do
        allow(User).to receive(:find_for_oauth).and_return(user)
        get :yandex
      end

      it 'login user' do
        expect(subject.current_user).to eq user
      end

      it 'redirects to rootpath' do
        expect(response).to redirect_to root_path
      end
    end

    context 'user does not exist' do
      before do
        allow(User).to receive(:find_for_oauth)
        get :yandex
      end

      it 'redirects to rootpath' do
        expect(response).to redirect_to root_path
      end

      it 'does not login user' do
        expect(subject.current_user).to_not be
      end
    end
  end
end