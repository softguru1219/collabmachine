# Set the host name for URL creation
# rake sitemap:refresh:no_ping

# SitemapGenerator::Sitemap.default_host = "https://collabmachine.com"
SitemapGenerator::Sitemap.default_host = "http://192.168.0.138:3000/"

SitemapGenerator.verbose = false

SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  locales = [:fr, :en]

  locales.each do |locale|
    add sectors_path(locale: locale), news: { title: "sectors" }

    Sector.all.each do |sector|
      add sector_path(locale: locale, id: sector.id),
          news: { title: (sector['name'][locale.to_s]).to_s, keywords: "sectors" }
    end

    add softwares_path(locale: locale), news: { title: "softwares" }
    Software.all.each do |software|
      add software_path(locale, software),
          news: { title: software.name.to_s, keywords: "softwares" }
    end

    BusinessSubDomain.all.each do |business_sub_domain|
      add business_domain_business_sub_domain_business_categories_path(
        locale: locale, business_domain_id: business_sub_domain.business_domain_id,
        business_sub_domain_id: business_sub_domain
),
          news: { title: (business_sub_domain['name'][locale.to_s]).to_s, keywords: "Business Sub Domain Categories" }
      add business_domain_business_sub_domain_path(
        locale: locale, business_domain_id: business_sub_domain.business_domain_id,
        id: business_sub_domain
),
          news: { title: (business_sub_domain['name'][locale.to_s]).to_s, keywords: "Business Sub Domains" }
    rescue Exception => e
      print("Error:", e.to_s)
    end

    BusinessCategory.all.each do |business_category|
      add business_domain_business_sub_domain_business_category_path(
        locale: locale, business_domain_id: business_category.business_sub_domain.business_domain_id,
        business_sub_domain_id: business_category.business_sub_domain_id,
        id: business_category
), news: { title: (business_category['name'][locale.to_s]).to_s, keywords: "Business Categories" }
    rescue Exception => e
      print("Error", e.to_s)
    end

    add business_domains_path(locale: locale), news: { title: "Business Domains" }
    BusinessDomain.all.each do |business_domain|
      add business_domain_path(locale: locale,
                               id: business_domain), news: { title: (business_domain['name'][locale.to_s]).to_s, keywords: "Business Domains" }
    end

    add user_steps_path(locale: locale), news: { title: "steps" }

    add trackers_path(locale: locale), news: { title: "trackers" }
    Tracker.all.each do |tracker|
      add tracker_path(locale: locale, id: tracker), news: { title: "trackers #{tracker.id}" }
    end

    add specialists_path(locale: locale), news: { title: "specialists" }
    Specialist.all.each do |specialist|
      add specialist_path(locale: locale, id: specialist), news: { title: "specialists #{specialist.id}", keywords: "specialists" }
    end

    add specialties_path(locale: locale), news: { title: 'specialties' }
    Specialty.all.each do |specialty|
      add specialty_path(locale: locale, id: specialty), news: { title: specialty.title.to_s, keywords: "specialties" }
    end

    add invoices_path(locale: locale), news: { title: "invoices" }
    Invoice.all.each do |invoice|
      add invoice_path(locale: locale, id: invoice), news: { title: "invoices #{invoice.id}", keywords: "invoices" }
    end

    add import_coachs_path(locale: locale), news: { title: "coaches" }
    add import_participants_path(locale: locale), news: { title: "participants" }
    add reset_card_path(locale: locale), news: { title: "Card" }
    add testing_path(locale: locale), news: { title: "testing" }

    add shares_path(locale: locale), news: { title: "shares" }
    Share.all.each do |share|
      add share_path(locale: locale, id: share), news: { title: "shares #{share.id}", keywords: "shares" }
    end

    add feedback_path(locale: locale), news: { title: "feedback" }

    add projects_path(locale: locale), news: { title: "projects" }
    Project.all.each do |project|
      add project_path(locale: locale, id: project), news: { title: project.title.to_s, keywords: "projects" }
    end

    add submit_project_for_review_path(locale: locale), news: { title: "Project review" }
    add mark_project_reviewed_path(locale: locale), news: { title: "mark project reviewed" }
    add open_project_for_candidates_path(locale: locale), news: { title: "Open project for candidates" }
    add missions_path(locale: locale), news: { title: "missions" }
    Mission.all.each do |mission|
      add mission_path(locale: locale, id: mission), news: { title: (mission.tot
                                                                     e).to_s, keywords: "missions" }
    end

    add submit_mission_for_review_path(locale: locale), news: { title: "Mission for review" }
    add mark_mission_reviewed_path(locale: locale), news: { title: "Mark mission reviewed" }
    add open_mission_for_candidates_path(locale: locale), news: { title: "Open mission for candidates" }
    add start_path(locale: locale), news: { title: "Start" }
    add finish_path(locale: locale), news: { title: "Finish" }
    add reopen_path(locale: locale), news: { title: "Reopen" }
    add archive_path(locale: locale), news: { title: "archive" }
    add mission_hold_path(locale: locale), news: { title: "mission hold" }
    add project_hold_path(locale: locale), news: { title: "project hold" }

    add messages_path(locale: locale), news: { title: "messages" }
    Message.all.each do |message|
      add message_path(locale: locale, id: message), news: { title: "messages #{message.id}", keywords: "messages" }
    end

    add financial_infos_path(locale: locale), news: { title: "Financial infos" }
    FinancialInfo.all.each do |financial_info|
      add financial_info_path(locale: locale, id: financial_info),
          news: { title: "Financial infos #{financial_info.id}", keywords: "Financial infos" }
    end

    add estimates_path(locale: locale), news: { title: "Estimates" }
    Estimate.all.each do |estimate|
      add estimate_path(locale: locale, id: estimate), news: { title: estimate.title.to_s, keywords: "Estimates" }
    end

    add tag_cloud_tags_path(locale: locale), news: { title: "Cloud tags" }
    add tags_path(locale: locale), news: { title: "tags" }
    Tag.all.each do |tag|
      add tag_path(locale: locale, id: tag), news: { title: tag.name.to_s, keywords: "tags" }
    end

    add machines_path(locale: locale), news: { title: "machines" }

    add exchanges_path(locale: locale), news: { title: "exchanges" }
    add accept_terms_path(locale: locale), news: { title: "Accept terms" }
    add contact_path(locale: locale), news: { title: "contact" }
    add dashboard_path(locale: locale), news: { title: "dashboard" }
    add metrics_path(locale: locale), news: { title: "Metrics" }
    add dashboard_admin_missions_path(locale: locale), news: { title: "admin dashboard missions" }
    add dashboard_admin_users_path(locale: locale), news: { title: "admin dashboard users" }
    add participation_system_path(locale: locale), news: { title: "participation system" }
    add slack_users_path(locale: locale), news: { title: "Slack users" }
    add master_service_agreement_path(locale: locale), news: { title: "Master service agrrement" }
    add get_contract_data_path(locale: locale), news: { title: "Contact data" }
    add blitz_coaching_path(locale: locale), news: { title: "Blitz coaching" }
    add blitz_coachs_path(locale: locale), news: { title: "Blitz coaches" }
    add blitz_participants_path(locale: locale), news: { title: "Blitz participants" }
    add blitz_logs_path(locale: locale), news: { title: "Blitz logs" }
    add blitz_followup_path(locale: locale), news: { title: "Blitz followup" }
    add blitz_meeting_participants_path(locale: locale), news: { title: "Blitz meeting participants" }
    add ten_slides_path(locale: locale), news: { title: "Ten sliders" }
    add digital_entrepreneurs_path(locale: locale), news: { title: "Digital entrepreneurs" }
    add landing_first_path(locale: locale), news: { title: "First landing" }
    add landing_path(locale: locale), news: { title: "landing" }
    add payment_path(locale: locale), news: { title: "payment" }
    add payment_gateway_path(locale: locale), news: { title: "payment gateway" }
    add mastermind_pointdebascule_path(locale: locale), news: { title: "mastermind pointdebascule" }
    add trousse_participant_automne_2021_path(locale: locale), news: { title: "trousse participant automne 2021" }
    add sandbox_program_path(locale: locale), news: { title: "sandbox program" }
    add your_serviceplace_path(locale: locale), news: { title: "ServicePlace" }
    add invite_for_specialties_path(locale: locale), news: { title: "invite for specialties" }
    add get_contracts_path(locale: locale), news: { title: "Contracts" }
    add get_specialist_path(locale: locale), news: { title: "specialist" }
    add propose_project_path(locale: locale), news: { title: "propose project" }
    add sandbox_path(locale: locale), news: { title: "sandbox" }
    add styledeck_path(locale: locale), news: { title: "styledeck" }
    add hire_path(locale: locale), news: { title: "hire" }
    add work_path(locale: locale), news: { title: "work" }
    add team_path(locale: locale), news: { title: "team" }
    add partners_path(locale: locale), news: { title: "partners" }
    add randomly_path(locale: locale), news: { title: "randomly" }
    add checkout_cancel_path(locale: locale), news: { title: "checkout cancel" }
    add admin_products_path(locale: locale), news: { title: "admin products" }

    add products_path(locale: locale), news: { title: "products" }
    Product.all.each do |product|
      add admin_product_path(locale: locale, id: product),
          news: { title: "Admin Projects #{product['title'][locale.to_s]}", keywords: "products" }
      add product_specific_user_reviews_path(locale: locale,
                                             product_id: product.id), news: { title: "Product specific reviews #{product['title'][locale.to_s]}", keywords: "products" }
      add publish_product_path(locale: locale, id: product), news: { title: "Publish product #{product['title'][locale.to_s]}", keywords: "products" }
      add archive_product_path(locale: locale, id: product), news: { title: "archive product #{product['title'][locale.to_s]}", keywords: "products" }
      add reject_product_path(locale: locale, id: product), news: { title: "Reject product #{product['title'][locale.to_s]}", keywords: "products" }
      add embed_product_path(locale: locale, id: product), news: { title: "Embed product #{product['title'][locale.to_s]}", keywords: "products" }
      add embed_graphic_product_path(locale: locale, id: product), news: { title: "Embed graphic product #{product['title'][locale.to_s]}", keywords: "products" }
      add embed_link_product_path(locale: locale, id: product), news: { title: "Embed link product #{product['title'][locale.to_s]}", keywords: "products" }
      add save_product_product_recommendations_path(locale: locale, id: product),
          news: { title: "#{product['title'][locale.to_s]} recommendations", keywords: "products" }
      add product_path(locale: locale, id: product),
          news: { title: (product['title'][locale.to_s]).to_s, keywords: "products" }
    end

    add admin_orders_path(locale: locale), news: { title: "Admin orders" }

    add checkout_success_path(locale: locale), news: { title: "feedback" }
    ProductCategory.all.each do |product_category|
      add serviceplace_product_category_path(locale: locale, id: product_category), news: { title: "Serviceplace product categories #{product_category.id}" }
    end

    add serviceplace_path(locale: locale), news: { title: "serviceplace" }
    add subscription_plans_path(locale: locale), news: { title: "subscription plans" }
    add confirm_payment_information_serviceplace_checkout_path(locale: locale), news: { title: "Payment information serviceplace" }
    add confirm_purchase_serviceplace_checkout_path(locale: locale), news: { title: "Purchase seviceplace checkout" }
    add view_invoice_serviceplace_checkout_path(locale: locale), news: { title: "Invoice serviceplace checkout" }
    add serviceplace_checkout_path(locale: locale), news: { title: "Serviceplace checkout" }
    add success_subscription_checkouts_path(locale: locale), news: { title: "Subscription checkouts" }
    add purchases_path(locale: locale), news: { title: "purchases" }

    Purchase.all.each do |purchase|
      add purchase_path(locale: locale, id: purchase), news: { title: "purchases #{purchase.id}" }
    end

    add orders_path(locale: locale), news: { title: "orders" }
    Order.all.each do |order|
      add invoice_order_path(locale: locale, id: order), news: { title: "Invoice orders #{order.id}", keywords: "orders" }
      add order_path(locale: locale, id: order), news: { title: "orders #{order.id}", keywords: "orders" }
    end

    add posts_path(locale: locale), news: { title: "posts" }
    Post.all.each do |post|
      add post_path(locale: locale, id: post), news: { title: post.title.to_s, keywords: "posts" }
    end

    add pages_path(locale: locale), news: { title: "pages" }
    Page.all.each do |page|
      add page_path(locale: locale, id: page), news: { title: page.title.to_s, keywords: "pages" }
    end

    add blog_path(locale: locale), news: { title: "blog" }
    add all_tags_path, news: { title: "All tags" }
  end
end