class Dashboard::SettingsController < Dashboard::BaseController
  def edit
  end

  def update
    # Merge nested JSON fields manually since they're stored as JSONB
    attrs = params.require(:restaurant).permit(:name, :slug, :description, :tagline, :currency, :timezone, :locale, :tax_rate, :google_business_url)

    if params[:restaurant][:hours].present?
      hours = {}
      params[:restaurant][:hours].each do |day, vals|
        hours[day] = {
          "open" => vals[:open] || "11:00",
          "close" => vals[:close] || "22:00",
          "closed" => vals[:closed] == "true"
        }
      end
      attrs[:hours] = hours
    end

    if params[:restaurant][:settings].present?
      settings = @restaurant.settings || {}
      if params[:restaurant][:settings][:orderTypes].present?
        settings["orderTypes"] = params[:restaurant][:settings][:orderTypes].to_unsafe_h.transform_values { |v| v == "true" }
      end
      if params[:restaurant][:settings][:dineInMode].present?
        settings["dineInMode"] = params[:restaurant][:settings][:dineInMode]
      end
      attrs[:settings] = settings
    end

    if params[:restaurant][:address].present?
      attrs[:address] = params[:restaurant][:address].to_unsafe_h
    end

    @restaurant.update!(attrs)
    redirect_to edit_dashboard_settings_path, notice: "Settings updated."
  end
end
