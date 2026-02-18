# frozen_string_literal: true

class PlayersController < ApplicationController
  before_action :set_player, only: %i[show edit update destroy]

  def index
    @players = Player.order(:last_name, :first_name).page(params[:page]).per(10)
  end

  def show; end

  def stats
    @player = Player.find(params[:id])
    @total_matches = Match.where('player_a_id = :id OR player_b_id = :id', id: @player.id).count
    @wins = @player.wins.count
    @losses = @player.losses.count
    @win_rate = @total_matches > 0 ? ((@wins.to_f / @total_matches) * 100).round(1) : 0.0
    @matches = Match.includes(:player_a, :player_b, :winner, :loser, :venue).where('player_a_id = :id OR player_b_id = :id', id: @player.id).order(created_at: :desc)
  end

  def new
    @player = Player.new
    @countries = Country.order(:name)
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to @player, notice: "Player was created."
    else
      @countries = Country.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @countries = Country.order(:name)
  end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: "Player was updated."
    else
      @countries = Country.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: "Player was deleted."
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:first_name, :last_name, :country_id)
  end
end

