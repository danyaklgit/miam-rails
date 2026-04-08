class Api::AnalyticsController < Api::BaseController
  def show
    restaurant = Restaurant.find(params[:id])
    period = params[:period] || "30d"
    days = { "7d" => 7, "30d" => 30, "90d" => 90 }[period] || 30
    start_date = days.days.ago.beginning_of_day

    case params[:type]
    when "overview"
      today_orders = restaurant.orders.where("created_at >= ?", Date.current.beginning_of_day)
      all_orders = restaurant.orders
      render json: {
        today: {
          orders: today_orders.count,
          revenue: today_orders.where(status: "completed").sum(:total_amount),
          tips: today_orders.joins(:payments).sum("payments.tip_amount")
        },
        allTime: {
          orders: all_orders.count,
          revenue: all_orders.where(status: "completed").sum(:total_amount),
          tips: all_orders.joins(:payments).sum("payments.tip_amount")
        },
        activeSessions: restaurant.dining_sessions.active.count,
        tableCount: restaurant.restaurant_tables.count,
        menuItemCount: restaurant.menu_items.count
      }

    when "revenue"
      orders = restaurant.orders.where("created_at >= ?", start_date)
      render json: {
        daily: orders.where(status: "completed")
          .group("DATE(created_at)")
          .select("DATE(created_at) as day, COUNT(*) as orders, SUM(total_amount) as revenue, SUM(tip_amount) as tips"),
        byType: orders.group(:type)
          .select("type, COUNT(*) as count, SUM(total_amount) as revenue")
      }

    when "popular-items"
      limit = (params[:limit] || 10).to_i
      items = restaurant.orders.where("orders.created_at >= ?", start_date)
        .joins(:order_items)
        .group("order_items.name")
        .select("order_items.name, SUM(order_items.quantity) as total_quantity, COUNT(DISTINCT orders.id) as order_count, SUM(order_items.price * order_items.quantity) as total_revenue")
        .order("total_quantity DESC")
        .limit(limit)
      render json: { items: items }

    when "peak-hours"
      heatmap = restaurant.orders.where("created_at >= ?", start_date)
        .group("EXTRACT(DOW FROM created_at)::int", "EXTRACT(HOUR FROM created_at)::int")
        .count
        .map { |(dow, hour), count| { dayOfWeek: dow, hour: hour, orderCount: count } }
      render json: { heatmap: heatmap }

    when "tips"
      orders = restaurant.orders.where("created_at >= ?", start_date)
      tipped = orders.joins(:payments).where("payments.tip_amount > 0")
      total_tips = orders.joins(:payments).sum("payments.tip_amount")
      total_orders = orders.count
      render json: {
        tippedOrders: tipped.distinct.count,
        totalOrders: total_orders,
        totalTips: total_tips,
        avgTip: tipped.distinct.count > 0 ? total_tips / tipped.distinct.count : 0,
        tipRate: total_orders > 0 ? (tipped.distinct.count.to_f / total_orders * 100).round(1) : 0
      }

    when "reviews"
      reviews = restaurant.reviews
      recent = reviews.order(created_at: :desc).limit(10)
      render json: {
        totalReviews: reviews.count,
        avgRating: reviews.average(:rating)&.round(1) || 0,
        googleRedirects: reviews.where(redirected_to_google: true).count,
        recentReviews: recent.map { |r| { id: r.id, rating: r.rating, feedback: r.feedback, createdAt: r.created_at } }
      }

    else
      render json: { error: "Unknown analytics type" }, status: :not_found
    end
  end
end
