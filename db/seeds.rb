puts "Seeding demo restaurant..."

# 1. Restaurant
restaurant = Restaurant.find_or_create_by!(slug: "chez-marcel") do |r|
  r.name = "Chez Marcel"
  r.description = "Authentic Belgian brasserie in the heart of Brussels"
  r.tagline = "Traditional Belgian cuisine since 1987"
  r.address = { "street" => "Rue de la Bourse 12", "city" => "Brussels", "postalCode" => "1000", "country" => "BE" }
  r.cuisine = ["Belgian", "French", "Brasserie"]
  r.hours = {
    "monday"    => { "open" => "11:30", "close" => "22:00", "closed" => false },
    "tuesday"   => { "open" => "11:30", "close" => "22:00", "closed" => false },
    "wednesday" => { "open" => "11:30", "close" => "22:00", "closed" => false },
    "thursday"  => { "open" => "11:30", "close" => "22:00", "closed" => false },
    "friday"    => { "open" => "11:30", "close" => "23:00", "closed" => false },
    "saturday"  => { "open" => "11:30", "close" => "23:00", "closed" => false },
    "sunday"    => { "open" => "12:00", "close" => "21:00", "closed" => false }
  }
  r.settings = {
    "orderTypes" => { "dineIn" => true, "takeaway" => true, "delivery" => false },
    "dineInMode" => "ordering",
    "requiresAccount" => { "takeaway" => false, "delivery" => true }
  }
  r.theme = {
    "primaryColor" => "#7c3aed",
    "secondaryColor" => "#f59e0b",
    "backgroundColor" => "#ffffff",
    "textColor" => "#1f2937",
    "fontFamily" => "Playfair Display",
    "bannerImageUrl" => "",
    "backgroundImageUrl" => "",
    "logoUrl" => "",
    "menuStyle" => "cards"
  }
  r.stripe = {
    "stripeAccountId" => "",
    "platformFeePercent" => 2,
    "pricingModel" => "transaction",
    "onboardingComplete" => false
  }
  r.owner_id = "demo-owner"
  r.status = "active"
end
puts "  ✓ Restaurant \"#{restaurant.name}\" (#{restaurant.id})"

# 2. Main Menu
main_menu = Menu.find_or_create_by!(restaurant: restaurant, name: "Main Menu") do |m|
  m.description = "Our full à la carte menu"
  m.is_active = true
  m.schedule = { "type" => "always", "days" => [], "startTime" => "", "endTime" => "" }
  m.sort_order = 0
end

# 3. Lunch Menu
lunch_menu = Menu.find_or_create_by!(restaurant: restaurant, name: "Lunch Menu") do |m|
  m.description = "Weekday lunch specials"
  m.is_active = true
  m.schedule = {
    "type" => "scheduled",
    "days" => %w[monday tuesday wednesday thursday friday],
    "startTime" => "11:30",
    "endTime" => "14:30"
  }
  m.sort_order = 1
end

# 4. Main Menu Categories + Items
main_categories = [
  {
    name: "Starters", description: "To begin your meal", sort_order: 0,
    items: [
      { name: "Croquettes aux crevettes", description: "Crispy shrimp croquettes with parsley and lemon", price: 14.50, type: "food", allergens: %w[crustaceans gluten eggs] },
      { name: "Soupe à l'oignon", description: "French onion soup gratinée with Gruyère", price: 9.50, type: "food", allergens: %w[milk gluten] },
      { name: "Salade de chèvre chaud", description: "Warm goat cheese salad with honey and walnuts", price: 12.00, type: "food", allergens: %w[milk nuts] },
      { name: "Tartare de saumon", description: "Fresh salmon tartare with avocado and citrus dressing", price: 15.00, type: "food", allergens: %w[fish] }
    ]
  },
  {
    name: "Mains", description: "Our signature dishes", sort_order: 1,
    items: [
      { name: "Moules-frites", description: "Classic Belgian mussels in white wine sauce with crispy fries", price: 22.00, type: "food", allergens: %w[molluscs milk] },
      { name: "Steak-frites", description: "300g Black Angus entrecôte with béarnaise sauce and fries", price: 28.50, type: "food", allergens: %w[eggs milk] },
      { name: "Waterzooi de poulet", description: "Traditional Ghent-style chicken stew in creamy broth", price: 19.50, type: "food", allergens: %w[milk celery] },
      { name: "Vol-au-vent", description: "Puff pastry filled with chicken, mushrooms and cream sauce", price: 18.00, type: "food", allergens: %w[gluten milk eggs] },
      { name: "Filet de cabillaud", description: "Pan-seared cod fillet with beurre blanc and seasonal vegetables", price: 24.00, type: "food", allergens: %w[fish milk] }
    ]
  },
  {
    name: "Desserts", description: "Something sweet to finish", sort_order: 2,
    items: [
      { name: "Gaufre de Liège", description: "Warm Liège waffle with vanilla ice cream and chocolate sauce", price: 9.50, type: "food", allergens: %w[gluten eggs milk] },
      { name: "Crème brûlée", description: "Classic vanilla crème brûlée with caramelized sugar", price: 8.50, type: "food", allergens: %w[milk eggs] },
      { name: "Dame blanche", description: "Vanilla ice cream with warm Belgian chocolate sauce", price: 8.00, type: "food", allergens: %w[milk] },
      { name: "Tarte Tatin", description: "Upside-down caramelized apple tart with crème fraîche", price: 10.00, type: "food", allergens: %w[gluten milk eggs] }
    ]
  },
  {
    name: "Drinks", description: "Beers, wines, and more", sort_order: 3,
    items: [
      { name: "Chimay Bleue", description: "Belgian Trappist dark ale, 33cl", price: 6.50, type: "drink", allergens: %w[gluten] },
      { name: "Orval", description: "Trappist pale ale with dry hop finish, 33cl", price: 6.00, type: "drink", allergens: %w[gluten] },
      { name: "Duvel", description: "Strong Belgian golden ale, 33cl", price: 5.50, type: "drink", allergens: %w[gluten] },
      { name: "Côtes du Rhône Rouge", description: "Glass of red wine", price: 7.00, type: "drink", allergens: %w[sulphites] },
      { name: "Sancerre Blanc", description: "Glass of white wine", price: 8.00, type: "drink", allergens: %w[sulphites] },
      { name: "Spa Reine", description: "Still mineral water, 50cl", price: 3.50, type: "drink", allergens: [] },
      { name: "Coca-Cola", description: "33cl", price: 3.50, type: "drink", allergens: [] },
      { name: "Espresso", description: "Italian espresso", price: 2.80, type: "drink", allergens: [] },
      { name: "Café Liégeois", description: "Iced coffee with vanilla ice cream and whipped cream", price: 7.50, type: "drink", allergens: %w[milk] }
    ]
  }
]

main_categories.each do |cat_data|
  category = Category.find_or_create_by!(menu: main_menu, restaurant: restaurant, name: cat_data[:name]) do |c|
    c.description = cat_data[:description]
    c.sort_order = cat_data[:sort_order]
  end

  cat_data[:items].each_with_index do |item_data, i|
    MenuItem.find_or_create_by!(category: category, menu: main_menu, restaurant: restaurant, name: item_data[:name]) do |mi|
      mi.description = item_data[:description]
      mi.price = item_data[:price]
      mi.type = item_data[:type]
      mi.allergens = item_data[:allergens]
      mi.sort_order = i
    end
  end
  puts "  ✓ [Main Menu] \"#{cat_data[:name]}\" — #{cat_data[:items].length} items"
end

# 5. Lunch Menu Categories + Items
lunch_categories = [
  {
    name: "Lunch Specials", description: "Quick and affordable", sort_order: 0,
    items: [
      { name: "Plat du jour", description: "Chef's daily special with side salad", price: 14.00, type: "food", allergens: [] },
      { name: "Croque Monsieur", description: "Grilled ham and cheese sandwich with fries", price: 11.50, type: "food", allergens: %w[gluten milk] },
      { name: "Salade César", description: "Caesar salad with grilled chicken", price: 13.00, type: "food", allergens: %w[eggs milk fish] }
    ]
  },
  {
    name: "Lunch Drinks", description: "", sort_order: 1,
    items: [
      { name: "Eau plate", description: "Still water, 50cl", price: 2.50, type: "drink", allergens: [] },
      { name: "Café", description: "Coffee", price: 2.50, type: "drink", allergens: [] },
      { name: "Thé", description: "Selection of teas", price: 2.80, type: "drink", allergens: [] }
    ]
  }
]

lunch_categories.each do |cat_data|
  category = Category.find_or_create_by!(menu: lunch_menu, restaurant: restaurant, name: cat_data[:name]) do |c|
    c.description = cat_data[:description]
    c.sort_order = cat_data[:sort_order]
  end

  cat_data[:items].each_with_index do |item_data, i|
    MenuItem.find_or_create_by!(category: category, menu: lunch_menu, restaurant: restaurant, name: item_data[:name]) do |mi|
      mi.description = item_data[:description]
      mi.price = item_data[:price]
      mi.type = item_data[:type]
      mi.allergens = item_data[:allergens]
      mi.sort_order = i
    end
  end
  puts "  ✓ [Lunch Menu] \"#{cat_data[:name]}\" — #{cat_data[:items].length} items"
end

# 6. Tables (10 tables)
10.times do |i|
  n = i + 1
  RestaurantTable.find_or_create_by!(restaurant: restaurant, number: n) do |t|
    t.capacity = n <= 4 ? 2 : n <= 8 ? 4 : 6
    t.qr_code_url = "https://miam.digital/chez-marcel/table/#{n}"
  end
end
puts "  ✓ 10 tables created"

# 7. Sample active session on table 3 with an order
table3 = RestaurantTable.find_by!(restaurant: restaurant, number: 3)
session = DiningSession.find_or_create_by!(restaurant: restaurant, restaurant_table: table3, status: "active") do |s|
  s.created_at = 25.minutes.ago
end

member1_id = "guest-abc123"
member2_id = "guest-def456"

SessionMember.find_or_create_by!(dining_session: session, user_id: member1_id) do |m|
  m.display_name = "Alice"
end
SessionMember.find_or_create_by!(dining_session: session, user_id: member2_id) do |m|
  m.display_name = "Bob"
end

order = Order.find_or_create_by!(restaurant: restaurant, session_id: session.id) do |o|
  o.type = "dineIn"
  o.status = "confirmed"
  o.table_id = table3.id
  o.total_amount = 62.50
end

session.update!(order_id: order.id)

# Sample order items in various statuses
sample_items = [
  { name: "Croquettes aux crevettes", price: 14.50, type: "food", status: "served", ordered_by: member1_id },
  { name: "Moules-frites", price: 22.00, type: "food", status: "preparing", ordered_by: member1_id },
  { name: "Steak-frites", price: 28.50, type: "food", status: "ordered", ordered_by: member2_id },
  { name: "Chimay Bleue", price: 6.50, type: "drink", status: "ready", ordered_by: member1_id },
  { name: "Duvel", price: 5.50, type: "drink", status: "served", ordered_by: member2_id },
  { name: "Crème brûlée", price: 8.50, type: "food", status: "ordered", ordered_by: member2_id }
]

sample_items.each do |item_data|
  OrderItem.find_or_create_by!(order: order, name: item_data[:name], ordered_by: item_data[:ordered_by]) do |oi|
    oi.price = item_data[:price]
    oi.type = item_data[:type]
    oi.status = item_data[:status]
    oi.quantity = 1
  end
end
puts "  ✓ Active session on table 3 with 6 order items"

# 8. Sample takeaway order
takeaway = Order.find_or_create_by!(restaurant: restaurant, type: "takeaway", status: "preparing", promo_code: nil, session_id: nil) do |o|
  o.total_amount = 33.50
  o.customer_info = { "name" => "Sophie Dupont", "email" => "sophie@example.com", "phone" => "+32 470 12 34 56" }
  o.pickup_time = 30.minutes.from_now
end

[
  { name: "Salade César", price: 13.00, type: "food", status: "preparing" },
  { name: "Croque Monsieur", price: 11.50, type: "food", status: "ordered" },
  { name: "Gaufre de Liège", price: 9.50, type: "food", status: "ordered" }
].each do |item_data|
  OrderItem.find_or_create_by!(order: takeaway, name: item_data[:name], ordered_by: "sophie-device") do |oi|
    oi.price = item_data[:price]
    oi.type = item_data[:type]
    oi.status = item_data[:status]
    oi.quantity = 1
  end
end
puts "  ✓ Takeaway order (Sophie Dupont)"

# 9. Sample reservations
[
  { date: Date.current.to_s, time: "19:00", party_size: 4, customer_name: "Jean-Pierre Martin", customer_phone: "+32 470 99 88 77", customer_email: "jp@example.com", status: "confirmed" },
  { date: Date.current.to_s, time: "19:30", party_size: 2, customer_name: "Marie Leclerc", customer_phone: "+32 470 11 22 33", customer_email: "marie@example.com", status: "confirmed" },
  { date: Date.current.to_s, time: "20:00", party_size: 6, customer_name: "Thomas Dubois", customer_phone: "+32 470 44 55 66", customer_email: "thomas@example.com", status: "confirmed", notes: "Birthday celebration, need cake" },
  { date: Date.current.to_s, time: "18:00", party_size: 3, customer_name: "Isabelle Petit", customer_phone: "+32 470 77 88 99", status: "seated" },
  { date: Date.tomorrow.to_s, time: "12:30", party_size: 2, customer_name: "Luc Janssen", customer_phone: "+32 470 00 11 22", customer_email: "luc@example.com", status: "confirmed" }
].each do |res_data|
  Reservation.find_or_create_by!(restaurant: restaurant, date: res_data[:date], time: res_data[:time], customer_name: res_data[:customer_name]) do |r|
    r.party_size = res_data[:party_size]
    r.customer_phone = res_data[:customer_phone] || ""
    r.customer_email = res_data[:customer_email] || ""
    r.status = res_data[:status]
    r.notes = res_data[:notes]
  end
end
puts "  ✓ 5 reservations (4 today, 1 tomorrow)"

# 10. Owner
Owner.find_or_create_by!(user_id: "demo-owner") do |o|
  o.restaurants = [restaurant.id]
end
puts "  ✓ Owner created"

# 11. Demo user (password login for development)
user = User.find_or_create_by!(email: "danyakl.da@gmail.com") do |u|
  u.password = "password123"
  u.name = "Dan"
  u.role = "owner"
  u.uid = "demo-owner"
end
puts "  ✓ Demo user: #{user.email} / password123"

puts "\n✅ Demo restaurant seeded!"
