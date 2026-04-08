class Dashboard::ThemesController < Dashboard::BaseController
  def edit
  end

  def update
    theme = @restaurant.theme || {}
    theme.merge!(theme_params.to_h)
    @restaurant.update!(theme: theme)
    redirect_to edit_dashboard_theme_path, notice: "Theme updated."
  end

  private

  def theme_params
    params.require(:theme).permit(:primaryColor, :secondaryColor, :backgroundColor, :textColor, :fontFamily, :menuStyle, :bannerImageUrl, :backgroundImageUrl, :logoUrl)
  end
end
