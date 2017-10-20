require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'GET /' do
    subject { get :status }

    it { is_expected.to be_ok }

    it 'returns json' do
      expect(JSON.parse(subject.body)).to eq 'status' => 'online'
    end
  end

end
