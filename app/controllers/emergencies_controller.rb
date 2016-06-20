class EmergenciesController < ApplicationController
  before_action :set_emergency, only: [:show, :edit, :destroy]

  # GET /emergencies
  # GET /emergencies.json
  def index
    @emergencies = Emergency.all
    # @emergencies.merge(full_responces: [1,3])
    render json: @emergencies
  end

  # GET /emergencies/1
  # GET /emergencies/1.json
  def show
    render json: { emergency: @emergency }
  end

  # GET /emergencies/new
  def new
    @emergency = Emergency.new
  end

  # GET /emergencies/1/edit
  def edit
  end

  # POST /emergencies
  # POST /emergencies.json
  def create
    @emergency = Emergency.new(emergency_params)

    if @emergency.save
      render status: :created, json: { emergency: @emergency }
    else
      render json: { message: @emergency.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /emergencies/1
  # PATCH/PUT /emergencies/1.json
  def update
    @emergency = Emergency.where(code: params[:code]).first
    if @emergency.update(emergency_update_params)
      render json: { emergency: @emergency }
    else
      render json: @emergency.errors, status: :unprocessable_entity
    end
  end

  # DELETE /emergencies/1
  # DELETE /emergencies/1.json
  def destroy
    @emergency.destroy
    respond_to do |format|
      format.html { redirect_to emergencies_url, notice: 'Emergency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_emergency
    @emergency = Emergency.where(code: params[:code]).first!
  end

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end

  def emergency_update_params
    params.require(:emergency).permit(:fire_severity, :police_severity, :medical_severity, :resolved_at)
  end
end
