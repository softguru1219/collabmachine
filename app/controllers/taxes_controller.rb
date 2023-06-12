class TaxesController < ApplicationController
  def create
    @tax = Tax.new(tax_params)
    @tax.user = current_user

    respond_to do |format|
      if @tax.save
        format.html { redirect_to user_path(current_user, anchor: 'finances'), notice: 'Tax was successfully created.' }
        format.json { render json: @tax.to_json }
      else
        format.html { redirect_to user_path(current_user, anchor: 'finances') }
        format.json { render json: @tax.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    tax = Tax.find(params[:id])
    tax.destroy
    respond_with tax, location: user_path(current_user, anchor: 'finances')
  end

  private

  def tax_params
    params.require(:tax).permit(:name, :rate, :number)
  end
end
