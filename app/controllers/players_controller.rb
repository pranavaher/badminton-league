# frozen_string_literal: true

class PlayersController < ApplicationController
  before_action :set_player, only: %i[show edit update destroy]

  def index
    @players = Player.order(:last_name, :first_name)
  end

  def show; end

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

