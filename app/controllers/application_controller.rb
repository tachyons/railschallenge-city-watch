class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound do
    flash[:notice] = 'The object you tried to access does not exist'
    render json: { 'message' => 'page not found' },status: :not_found 
  end
  rescue_from ActionController::UnpermittedParameters do |e|
    flash[:notice] = 'The object you tried to access does not exist'
    render json: {message: e.message},status: 422 
  end

end
