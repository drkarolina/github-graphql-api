# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubInfoController, type: :controller do
    describe "#index" do
        context "when renders" do
            before {get :index}
            it { expect(response).to have_http_status(:ok) }
            it { expect(response).to render_template(:index) }
        end
    end

    describe "#show" do
        context "when valid request" do
            before {get :show, params:{gh_login: "dhh"}}
            it { expect(response).to have_http_status(:ok) }
            it { expect(response).to render_template(:show) }
        end
        context "when invalid request" do
            before {get :show, params:{gh_login: "dhh123123123"}}
            it { expect(response).to have_http_status(:found) }
            it { expect(response).to redirect_to(root_url) }
        end
    end
end
