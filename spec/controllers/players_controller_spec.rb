require 'rails_helper'

RSpec.describe PlayersController, type: :controller do
  let(:user) { create(:user) }
  let(:country) { create(:country) }
  let(:player) { create(:player, country: country) }
  let(:valid_attributes) { { first_name: 'John', last_name: 'Doe', country_id: country.id } }
  let(:invalid_attributes) { { first_name: '', last_name: '', country_id: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns paginated players' do
      create_list(:player, 15)
      get :index
      expect(assigns(:players)).to be_present
      expect(assigns(:players).count).to eq(10) # default per page
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: player.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns requested player' do
      get :show, params: { id: player.id }
      expect(assigns(:player)).to eq(player)
    end
  end

  describe 'GET #stats' do
    let(:opponent) { create(:player) }
    let!(:win) { create(:match, player_a: player, player_b: opponent, winner: player) }
    let!(:loss) { create(:match, player_a: opponent, player_b: player, winner: opponent) }
    let!(:pending) { create(:match, player_a: player, player_b: opponent) }

    it 'returns http success' do
      get :stats, params: { id: player.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns player statistics' do
      get :stats, params: { id: player.id }
      expect(assigns(:wins)).to eq(1)
      expect(assigns(:losses)).to eq(1)
      expect(assigns(:total_matches)).to eq(2)
      expect(assigns(:pending_matches)).to eq(1)
    end

    it 'calculates correct win rate' do
      get :stats, params: { id: player.id }
      # 1 win out of 2 decided matches = 50%
      expect(assigns(:win_rate)).to eq(50.0)
    end

    it 'includes all player matches' do
      get :stats, params: { id: player.id }
      expect(assigns(:matches).count).to eq(3)
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'assigns new player' do
      get :new
      expect(assigns(:player)).to be_a_new(Player)
    end

    it 'assigns countries' do
      get :new
      expect(assigns(:countries)).to be_present
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new player' do
        expect {
          post :create, params: { player: valid_attributes }
        }.to change(Player, :count).by(1)
      end

      it 'redirects to player show' do
        post :create, params: { player: valid_attributes }
        expect(response).to redirect_to(Player.last)
      end

      it 'shows a success message' do
        post :create, params: { player: valid_attributes }
        expect(flash[:notice]).to include('created')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a player' do
        expect {
          post :create, params: { player: invalid_attributes }
        }.not_to change(Player, :count)
      end

      it 'renders new template' do
        post :create, params: { player: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: player.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns requested player' do
      get :edit, params: { id: player.id }
      expect(assigns(:player)).to eq(player)
    end

    it 'assigns countries' do
      get :edit, params: { id: player.id }
      expect(assigns(:countries)).to be_present
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      let(:new_attributes) { { first_name: 'Jane', last_name: 'Smith' } }

      it 'updates the player' do
        patch :update, params: { id: player.id, player: new_attributes }
        player.reload
        expect(player.first_name).to eq('Jane')
        expect(player.last_name).to eq('Smith')
      end

      it 'redirects to player' do
        patch :update, params: { id: player.id, player: new_attributes }
        expect(response).to redirect_to(player)
      end
    end

    context 'with invalid attributes' do
      it 'does not update player' do
        patch :update, params: { id: player.id, player: invalid_attributes }
        player.reload
        expect(player.first_name).not_to be_blank
      end

      it 'renders edit template' do
        patch :update, params: { id: player.id, player: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:player_to_delete) { create(:player) }

    it 'deletes the player' do
      expect {
        delete :destroy, params: { id: player_to_delete.id }
      }.to change(Player, :count).by(-1)
    end

    it 'redirects to players index' do
      delete :destroy, params: { id: player_to_delete.id }
      expect(response).to redirect_to(players_url)
    end
  end
end
