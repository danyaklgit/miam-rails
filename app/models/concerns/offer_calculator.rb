# Offer validation and discount calculation engine.
# Pure methods — no DB writes, fully testable.
module OfferCalculator
  extend ActiveSupport::Concern

  DAY_NAMES = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  class_methods do
    # Returns the best offer (highest discount) from a list of offers
    def best_offer(offers, order_type:, items:, order_total:, now: Time.current)
      best = nil

      offers.each do |offer|
        next unless offer_currently_active?(offer, now: now)
        next unless offer_applicable_to_order?(offer, order_type: order_type, order_total: order_total)

        discount = calculate_discount(offer, items: items, order_total: order_total)
        if discount > 0 && (best.nil? || discount > best[:discount])
          best = { offer: offer, discount: discount }
        end
      end

      best
    end

    # Checks if an offer is currently active based on schedule, redemptions, etc.
    def offer_currently_active?(offer, now: Time.current)
      return false unless offer.active?

      if offer.max_redemptions.present? && (offer.current_redemptions || 0) >= offer.max_redemptions
        return false
      end

      schedule = offer.schedule
      return true if schedule.blank?

      # Date range check
      if schedule["startDate"].present?
        return false if now < Time.parse(schedule["startDate"]).beginning_of_day
      end
      if schedule["endDate"].present?
        return false if now > Time.parse(schedule["endDate"]).end_of_day
      end

      # Day of week check
      days = schedule["days"]
      if days.present? && days.any?
        today_name = DAY_NAMES[now.wday]
        return false unless days.include?(today_name)
      end

      # Time range check
      if schedule["timeStart"].present? && schedule["timeEnd"].present?
        now_minutes = now.hour * 60 + now.min
        sh, sm = schedule["timeStart"].split(":").map(&:to_i)
        eh, em = schedule["timeEnd"].split(":").map(&:to_i)
        start_min = sh * 60 + sm
        end_min = eh * 60 + em
        return false if now_minutes < start_min || now_minutes > end_min
      end

      true
    end

    # Checks if an offer applies to a specific order type and meets minimum amount
    def offer_applicable_to_order?(offer, order_type:, order_total:)
      types = offer.order_types.presence || %w[dineIn takeaway delivery]
      return false unless types.include?(order_type)

      if offer.min_order_amount.present? && order_total < offer.min_order_amount.to_f
        return false
      end

      true
    end

    # Calculates the discount amount for an offer
    # items: array of { menu_item_id:, category_id:, price:, quantity: }
    def calculate_discount(offer, items:, order_total:)
      value = offer.value.to_f
      applies_to = offer.applies_to || { "items" => [], "categories" => [], "wholeOrder" => false }

      case offer.type
      when "percentage"
        if applies_to["wholeOrder"]
          (order_total * value / 100.0).round(2)
        else
          matching = items.select do |i|
            (i[:menu_item_id].present? && applies_to["items"].include?(i[:menu_item_id])) ||
            (i[:category_id].present? && applies_to["categories"].include?(i[:category_id]))
          end
          matching_total = matching.sum { |i| i[:price].to_f * (i[:quantity] || 1) }
          (matching_total * value / 100.0).round(2)
        end

      when "fixed"
        [value, order_total].min

      when "happyHour"
        matching = items.select do |i|
          applies_to["wholeOrder"] ||
          (i[:menu_item_id].present? && applies_to["items"].include?(i[:menu_item_id])) ||
          (i[:category_id].present? && applies_to["categories"].include?(i[:category_id]))
        end
        matching_total = matching.sum { |i| i[:price].to_f * (i[:quantity] || 1) }
        (matching_total * value / 100.0).round(2)

      when "bundle"
        required_items = applies_to["items"] || []
        has_all = required_items.all? { |req_id| items.any? { |i| i[:menu_item_id] == req_id } }
        has_all ? [value, order_total].min : 0

      else
        0
      end
    end
  end
end
