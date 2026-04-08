class Dashboard::TablesController < Dashboard::BaseController
  def index
    @tables = @restaurant.restaurant_tables.order(:number)
  end

  def create
    @restaurant.restaurant_tables.create!(table_params)
    redirect_to dashboard_tables_path, notice: "Table created."
  end

  def destroy
    table = @restaurant.restaurant_tables.find(params[:id])
    table.destroy!
    redirect_to dashboard_tables_path, notice: "Table deleted."
  end

  def bulk_create
    count = params[:count].to_i
    start_num = (@restaurant.restaurant_tables.maximum(:number) || 0) + 1
    count.times do |i|
      @restaurant.restaurant_tables.create!(
        number: start_num + i,
        capacity: params[:capacity] || 4,
        qr_code_url: "https://miam.digital/#{@restaurant.slug}/table/#{start_num + i}"
      )
    end
    redirect_to dashboard_tables_path, notice: "#{count} tables created."
  end

  private

  def table_params
    params.require(:restaurant_table).permit(:number, :capacity)
  end
end
