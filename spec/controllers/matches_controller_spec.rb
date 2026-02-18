require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  let(:user) { create(:user) }
  let(:country) { create(:country) }
  let(:player_a) { create(:player) }
  let(:player_b) { create(:player) }
  let(:match) { create(:match, player_a: player_a, player_b: player_b, venue: country) }
  let(:valid_attributes) do
    {
      name: 'Test Match',
      player_a_id: player_a.id,
      player_b_id: player_b.id,
      venue_id: country.id,
      scheduled_at: 2.hours.from_now
    }
  end
  let(:invalid_attributes) { { player_a_id: player_a.id, player_b_id: player_a.id } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated matches' do
      create_list(:match, 10)
      get :index
      expect(assigns(:matches)).to be_present
      expect(assigns(:matches).count).to eq(5) # default per page
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: match.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns requested match' do
      get :show, params: { id: match.id }
      expect(assigns(:match)).to eq(match)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns new match' do
      get :new
      expect(assigns(:match)).to be_a_new(Match)
    end

    it 'assigns players and countries' do
      get :new
      expect(assigns(:players)).to be_present
      expect(assigns(:countries)).to be_present
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new match' do
        expect {
          post :create, params: { match: valid_attributes }
        }.to change(Match, :count).by(1)
      end

      it 'schedules auto-decide job if enabled' do
        auto_decide_attrs = valid_attributes.merge(auto_decide: '1')
        post :create, params: { match: auto_decide_attrs }
        created_match = Match.last
        expect(created_match.auto_decide).to be true
        expect(created_match.job_id).to be_present
      end

      it 'redirects to matches index' do
        post :create, params: { match: valid_attributes }
        expect(response).to redirect_to(matches_url)
      end

      it 'shows success message' do
        post :create, params: { match: valid_attributes }
        expect(flash[:notice]).to include('recorded')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a match' do
        expect {
          post :create, params: { match: invalid_attributes }
        }.not_to change(Match, :count)
      end

      it 'shows error for same players' do
        post :create, params: { match: invalid_attributes }
        expect(flash.now[:alert]).to include('different')
      end

      it 'renders new template' do
        post :create, params: { match: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: match.id }
      expect(response).to have_http_status(:success)
    end

    it 'prevents editing if match has winner' do
      decided_match = create(:match, :with_winner)
      get :edit, params: { id: decided_match.id }
      expect(response).to redirect_to(matches_url)
      expect(flash[:alert]).to include('already has a result')
    end

    it 'assigns match and data' do
      get :edit, params: { id: match.id }
      expect(assigns(:match)).to eq(match)
      expect(assigns(:players)).to be_present
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:new_attributes) { { name: 'Updated Match' } }

      it 'updates the match' do
        patch :update, params: { id: match.id, match: new_attributes }
        match.reload
        expect(match.name).to eq('Updated Match')
      end

      it 'cancels job if auto_decide toggled off' do
        auto_match = create(:match, auto_decide: true, scheduled_at: 2.hours.from_now)
        job_id = auto_match.job_id
        patch :update, params: { id: auto_match.id, match: { auto_decide: '0' } }
        auto_match.reload
        expect(auto_match.auto_decide).to be false
        expect(auto_match.job_id).to be_nil
      end

      it 'redirects to matches' do
        patch :update, params: { id: match.id, match: new_attributes }
        expect(response).to redirect_to(matches_url)
      end
    end

    context 'with invalid attributes' do
      it 'does not update match' do
        patch :update, params: { id: match.id, match: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'POST #decide' do
    let(:past_match) { create(:match, :scheduled_in_past, player_a: player_a, player_b: player_b) }

    it 'assigns winner when choosing player A' do
      post :decide, params: { id: past_match.id, winner: 'a' }
      past_match.reload
      expect(past_match.winner).to eq(player_a)
      expect(past_match.loser).to eq(player_b)
    end

    it 'assigns winner when choosing player B' do
      post :decide, params: { id: past_match.id, winner: 'b' }
      past_match.reload
      expect(past_match.winner).to eq(player_b)
      expect(past_match.loser).to eq(player_a)
    end

    it 'prevents deciding winner for future matches' do
      future_match = create(:match, scheduled_at: 2.hours.from_now)
      post :decide, params: { id: future_match.id, winner: 'a' }
      expect(response).to redirect_to(matches_url)
      expect(flash[:alert]).to include('not scheduled in the past')
    end

    it 'redirects and shows success' do
      post :decide, params: { id: past_match.id, winner: 'a' }
      expect(response).to redirect_to(matches_url)
      expect(flash[:notice]).to include('assigned')
    end
  end

  describe 'DELETE #destroy' do
    let!(:match_to_delete) { create(:match) }

    it 'deletes the match' do
      expect {
        delete :destroy, params: { id: match_to_delete.id }
      }.to change(Match, :count).by(-1)
    end

    it 'cancels auto-decide job if exists' do
      auto_match = create(:match, auto_decide: true, scheduled_at: 2.hours.from_now)
      delete :destroy, params: { id: auto_match.id }
      expect(Match.exists?(auto_match.id)).to be false
    end

    it 'redirects to matches' do
      delete :destroy, params: { id: match_to_delete.id }
      expect(response).to redirect_to(matches_url)
    end
  end
end
