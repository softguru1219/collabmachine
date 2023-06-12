class FinancialInfosController < ApplicationController
  def new
    @info = FinancialInfo.new
    respond_with @info
  end

  def create
    @info = FinancialInfo.new(info_params)
    @info.user = current_user

    respond_to do |format|
      if @info.save
        format.html { redirect_to user_path(current_user, anchor: 'finances'), notice: 'Financial info was successfully created.' }
        format.json { render json: @info.to_json }
      else
        format.html { redirect_to user_path(current_user, anchor: 'finances') }
        format.json { render json: @info.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    info = FinancialInfo.find(params[:id])
    info.destroy
    respond_with info, location: user_path(current_user, anchor: 'finances')
  end

  private

  def info_params
    params.require(:financial_info).permit(:institution, :transit, :account)
  end
end
