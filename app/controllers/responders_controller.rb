class RespondersController < ApplicationController
  before_action :set_responder, only: [:show, :edit, :update, :destroy]

  # GET /responders
  # GET /responders.json
  def index
    @responders = Responder.all
    if params[:show] == 'capacity'
      render json: Responder.available_responders
    else
      render json: { responders: @responders }
    end
  end

  # GET /responders/1
  # GET /responders/1.json
  def show
    render json:  { responder: @responder }
  end

  # GET /responders/new
  def new
    @responder = Responder.new
  end

  # GET /responders/1/edit
  def edit
  end

  # POST /responders
  # POST /responders.json
  def create
    @responder = Responder.new(responder_params)

    if @responder.save
      render status: :created, json: { responder: @responder }
    else
      render json: { message: @responder.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /responders/1
  # PATCH/PUT /responders/1.json
  def update
    if @responder.update(responder_update_params)
      render json: { responder: @responder }
    else
      render json: @responder.errors, status: :unprocessable_entity
    end
  end

  # DELETE /responders/1
  # DELETE /responders/1.json
  def destroy
    @responder.destroy
    respond_to do |format|
      format.html { redirect_to responders_url, notice: 'Responder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_responder
    # @responder = Responder.find(params[:id])
    @responder = Responder.where(name: params[:name]).first!
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end

  def responder_update_params
    params.require(:responder).permit(:on_duty)
  end
end
