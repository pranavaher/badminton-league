class MatchesController < ApplicationController
  before_action :set_match, only: %i[show edit update destroy decide]
  before_action :prevent_edit_if_decided, only: %i[edit update]
  before_action :prevent_decide_if_not_scheduled, only: %i[decide]

  def index
    @matches = Match.includes(:winner, :loser).order(created_at: :desc)
  end

  def show; end

  def new
    @match = Match.new
    @players = Player.order(:last_name, :first_name)
    @countries = Country.order(:name)
  end

  def edit
    @players = Player.order(:last_name, :first_name)
    @countries = Country.order(:name)
  end

  def create
    # Quick server-side check to give a clear flash message when same players selected
    if match_params[:player_a_id].present? && match_params[:player_b_id].present? && match_params[:player_a_id] == match_params[:player_b_id]
      @match = Match.new(match_params)
      @players = Player.order(:last_name, :first_name)
      @countries = Country.order(:name)
      flash.now[:alert] = 'Player A and Player B must be different.'
      render :new
      return
    end

    @match = Match.new(match_params)
    if @match.save
      redirect_to matches_path, notice: 'Match recorded.'
    else
      @players = Player.order(:last_name, :first_name)
      @countries = Country.order(:name)
      render :new
    end
  end

  def update
    if match_params[:player_a_id].present? && match_params[:player_b_id].present? && match_params[:player_a_id] == match_params[:player_b_id]
      @players = Player.order(:last_name, :first_name)
      @countries = Country.order(:name)
      flash.now[:alert] = 'Player A and Player B must be different.'
      render :edit
      return
    end

    if @match.update(match_params)
      redirect_to matches_path, notice: 'Match updated.'
    else
      @players = Player.order(:last_name, :first_name)
      @countries = Country.order(:name)
      render :edit
    end
  end

  # POST /matches/:id/decide
  def decide
    winner_choice = params[:winner]
    begin
      @match.decide_winner!(winner_choice)
      redirect_to matches_path, notice: 'Winner assigned.'
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to matches_path, alert: "Could not assign winner: #{e.message}"
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_path, notice: 'Match deleted.'
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def prevent_edit_if_decided
    return unless @match.winner.present?

    redirect_to matches_path, alert: 'Match already has a result and cannot be modified.'
  end

  def prevent_decide_if_not_scheduled
    return if @match.can_decide_winner?

    redirect_to matches_path, alert: 'Match is not scheduled in the past. Cannot decide winner yet.'
  end

  def match_params
    params.require(:match).permit(:name, :player_a_id, :player_b_id, :scheduled_at, :venue_id)
  end
end
