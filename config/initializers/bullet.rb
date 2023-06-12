# ignore false positive when user is loaded in top nav for layout
Bullet.add_safelist type: :n_plus_one_query, class_name: "User", association: :avatar_attachment if defined?(Bullet)
