namespace :insert_data do
  task sectors: :environment do
    sectors = [
      { name_fr: 'Administrations publiques', name_en: 'Public administration',
        abr_fr: 'public', abr_en: 'public' },
      { name_fr: 'Agriculture, foresterie, pêche et chasse', name_en: 'Agriculture, forestry, fishing and hunting',
        abr_fr: 'agri', abr_en: 'agri' },
      { name_fr: 'Arts, spectacles et loisirs', name_en: 'Arts, entertainment and recreation',
        abr_fr: 'arts', abr_en: 'arts' },
      { name_fr: 'Autres services (sauf les administrations publiques)',
        name_en: 'Other services (except public administration)',
        abr_fr: 'services', abr_en: 'services' },
      { name_fr: 'Commerce de détail', name_en: 'Retail trade',
        abr_fr: 'detail', abr_en: 'detail' },
      { name_fr: 'Commerce de gros', name_en: 'Wholesale trade',
        abr_fr: 'gros', abr_en: 'Wholesale' },
      { name_fr: 'Construction', name_en: 'Construction',
        abr_fr: 'Construction', abr_en: 'Construction' },
      { name_fr: "Extraction minière, exploitation en carrière, et extraction de pétrole et de gaz",
        name_en: 'Mining, quarrying, and oil and gas extraction',
        abr_fr: 'mine', abr_en: 'Mining' },
      { name_fr: 'Fabrication', name_en: 'Manufacturing',
        abr_fr: 'fabrication', abr_en: 'manufacturing' },
      { name_fr: 'Finance et assurances', name_en: 'Finance and insurance',
        abr_fr: 'finance', abr_en: 'finance' },
      { name_fr: "Gestion de sociétés et d'entreprises", name_en: 'Management of companies and enterprises',
        abr_fr: 'gestion', abr_en: 'management' },
      { name_fr: "Industrie de l'information et industrie culturelle",
        name_en: 'Information and cultural industries',
        abr_fr: 'info', abr_en: 'info' },
      { name_fr: "Services administratifs, services de soutien, services de gestion des déchets et services d'assainissement",
        name_en: 'Administrative and support, waste management and remediation services', abr_fr: 'admin', abr_en: 'admin' },
      { name_fr: "Services d'enseignement", name_en: 'Educational services',
        abr_fr: 'edu', abr_en: 'edu' },
      { name_fr: "Services d'hébergement et de restauration", name_en: "Accommodation and food services",
        abr_fr: 'resto', abr_en: 'food' },
      { name_fr: "Services immobiliers et services de location et de location à bail",
        name_en: "Real estate and rental and leasing",
        abr_fr: 'immo', abr_en: 'estate' },
      { name_fr: "Services professionnels, scientifiques et techniques",
        name_en: "Professional, scientific and technical services",
        abr_fr: 'pro', abr_en: 'pro' },
      { name_fr: "Services publics", name_en: "services_publics",
        abr_fr: 'Utilities', abr_en: 'uilities' },
      { name_fr: "Soins de santé et assistance sociale", name_en: "Health care and social assistance",
        abr_fr: 'sante', abr_en: 'health' },
      { name_fr: "Transport et entreposage", name_en: "Transportation and warehousing",
        abr_fr: 'transport', abr_en: 'transport' }
    ]

    sectors.each do |st|
      sc = Sector.create(name_fr: st[:name_fr], name_en: st[:name_en],
                         abr_fr: st[:abr_fr], abr_en: st[:abr_en])
      sc.save!
    end
  end

  task business_domains: :environment do
    domains = [
      { name_en: 'Resources', name_fr: 'Ressources' },
      { name_en: 'ServicePlace', name_fr: 'ServicePlace' }
    ]

    domains.each do |domain|
      bd = BusinessDomain.create(name_en: domain[:name_en], name_fr: domain[:name_fr])
      bd.save!
    end
  end

  task business_subdomains: :environment do
    subdomains = [
      { name_en: 'Marketing', name_fr: 'Marketing', business_domain_id: 1 },
      { name_en: 'Computer science', name_fr: 'Informatique', business_domain_id: 1 }
    ]

    subdomains.each do |subdomain|
      bd = BusinessSubDomain.create(name_en: subdomain[:name_en], name_fr: subdomain[:name_fr],
                                    display_en: true, display_fr: true)
      bd.save!
    end
  end

  task business_categories_mkt: :environment do
    # for marketing
    business_sub_domain_id = 1
    categories = [
      { name_en: 'Non-Transactional Website Audit', name_fr: 'Audit site non transactionnel',
        abr_en: 'no_trx_audit', abr_fr: 'audit_no_trx', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'E-Commerce Website Audit', name_fr: 'Audit site e-commerce',
        abr_en: 'ecomm_audit', abr_fr: 'audit_ecomm', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Non-Transactional Website Audit + SM',
        name_fr: 'Audit site non transactionnel + RS',
        abr_en: 'no_trx__social_audit', abr_fr: 'audit_no_trx_social', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'E-Commerce Website Audit + SM', name_fr: 'Audit site e-commerce + RS',
        abr_en: 'ecomm_social_audit', abr_fr: 'audit_ecomm_social', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'B2B Strategic Plan', name_fr: 'Plan stratégique B2B',
        abr_en: 'b2b_strategic_plan', abr_fr: 'plan_strategique_b2b', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'B2C Strategic Plan', name_fr: 'Plan stratégique B2C',
        abr_en: 'b2c_strategic_plan', abr_fr: 'plan_strategique_b2c', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Dashboard', name_fr: 'Tableau de bord',
        abr_en: 'dashboard', abr_fr: 'tableau_de_bord', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Guide to Creating SM Content', name_fr: 'Guide de création de contenus RS',
        abr_en: 'guide_social_content', abr_fr: 'guide_contenu_social', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Project Management', name_fr: 'Gestion de projet',
        abr_en: 'project_management', abr_fr: 'gestion_projet', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Blog', name_fr: 'Blogue',
        abr_en: 'blog', abr_fr: 'blogue', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Newsletters', name_fr: 'Infolettres',
        abr_en: 'newsletters', abr_fr: 'infolettres', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Social Media Posts', name_fr: 'Post RS',
        abr_en: 'social_post', abr_fr: 'post_social', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Content Writing', name_fr: 'Rédaction de contenus',
        abr_en: 'content_wrt', abr_fr: 'redac', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Affiliate Program', name_fr: "Programme d'affiliation",
        abr_en: 'affiliate', abr_fr: 'affiliation', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Partnership', name_fr: 'Partenariat',
        abr_en: 'partnership', abr_fr: 'partenariat', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'SEO (Search Engine Optimisation)', name_fr: 'SEO (Search Engine Optimisation)seo',
        abr_en: 'seo', abr_fr: 'seo', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'SEM (Search engine marketing)', name_fr: 'SEM (Search engine marketing)',
        abr_en: 'sem', abr_fr: 'sem', business_sub_domain_id: business_sub_domain_id },
      { name_en: 'Business Model', name_fr: "Modèle d'affaires",
        abr_en: 'business_model', abr_fr: 'modele_affaires', business_sub_domain_id: business_sub_domain_id }
    ]

    categories.each do |category|
      bc = BusinessCategory.create(name_en: category[:name_en], name_fr: category[:name_fr],
                                   abr_en: category[:abr_en], abr_fr: category[:abr_fr], display_en: true, display_fr: true)
      bc.save!
    end
  end


  task business_categories_IT: :environment do
    # for IT
    business_sub_domain_id = 5
    categories = [
      { name_en: 'Artificial Intelligence - AI',
        name_fr: 'Intelligence Artificielle - IA',
        abr_en: 'ai',
        abr_fr: 'ia',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Augmented Reality',
        name_fr: 'Réalité augmentée',
        abr_en: 'aug_real',
        abr_fr: 'real_aug',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Big Data',
        name_fr: 'Big Data',
        abr_en: 'big_data',
        abr_fr: 'megadonnees',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Blockchain',
        name_fr: 'Blockchain',
        abr_en: 'blockchain',
        abr_fr: 'chaine_blocs',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Blockchain',
        name_fr: 'Blockchain',
        abr_en: 'blockchain',
        abr_fr: 'chaine_blocs',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Cloud & Infrastructure',
        name_fr: 'Infrastructure infonuagique',
        abr_en: 'cloud_infra',
        abr_fr: 'infra_nuage',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Cryptocurrency',
        name_fr: 'Cryptomonnaies',
        abr_en: 'Cryptocurr',
        abr_fr: 'Crypto',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Cybersecurity & Data Protection',
        name_fr: 'Cybersecurité et Protection des données',
        abr_en: 'cybersec',
        abr_fr: 'cyber_sec',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Data Science',
        name_fr: 'Science des données',
        abr_en: 'data_science',
        abr_fr: 'science_data',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Data Processing',
        name_fr: 'Traitement de données',
        abr_en: 'data_process',
        abr_fr: 'traitement_données',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Databases',
        name_fr: 'Bases de données',
        abr_en: 'databases',
        abr_fr: 'bases_donnees',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Desktop Applications',
        name_fr: 'Applications pour poste de travail',
        abr_en: 'desktop_app',
        abr_fr: 'app_poste_travail',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'E-Commerce Development',
        name_fr: 'Development E-Commerce',
        abr_en: 'ecom_dev',
        abr_fr: 'dev_ecom',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Embarqued systems',
        name_fr: 'Systèmes embarqués',
        abr_en: 'emb_sys',
        abr_fr: 'sys_emb',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Front-end Development',
        name_fr: 'Development Front-end',
        abr_en: 'front_dev',
        abr_fr: 'dev_front',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Game Development',
        name_fr: 'Development Jeux',
        abr_en: 'game_dev',
        abr_fr: 'dev_jeux',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Integration',
        name_fr: 'Intégration',
        abr_en: 'game_dev',
        abr_fr: 'dev_jeux',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Interface design',
        name_fr: 'Design interface',
        abr_en: 'ntface_design',
        abr_fr: 'desing_ntface',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'IOT - internet of things',
        name_fr: 'Ido - internet des objets',
        abr_en: 'iot',
        abr_fr: 'ido',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'IT Architecture',
        name_fr: 'Architecture informatique',
        abr_en: 'it_arch',
        abr_fr: 'arch_ti',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Machine Learning',
        name_fr: 'Apprentissage machine',
        abr_en: 'ML',
        abr_fr: 'appr_machine',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Mobile Apps',
        name_fr: 'Applications mobiles',
        abr_en: 'mobile_apps',
        abr_fr: 'app_mobile',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Multimedia',
        name_fr: 'Multimédia',
        abr_en: 'multimedia',
        abr_fr: 'multi_media',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'QA, Test specialist, Review',
        name_fr: 'Controle Qualité, tests et révision',
        abr_en: 'QA_specialist',
        abr_fr: 'contr_qualite',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'IT Support',
        name_fr: 'Support informatique',
        abr_en: 'it_support',
        abr_fr: 'support_ntic',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'User Experience - UX',
        name_fr: 'Experience utilisateur - UX',
        abr_en: 'user_exp_ux',
        abr_fr: 'exp_user_ux',
        business_sub_domain_id: business_sub_domain_id
      },
      { name_en: 'Web Programming',
        name_fr: 'Développement web',
        abr_en: 'web_dev',
        abr_fr: 'dev_web',
        business_sub_domain_id: business_sub_domain_id
      },
    ]

    categories.each do |category|
      bc = BusinessCategory.create(name_en: category[:name_en], name_fr: category[:name_fr],
                                   abr_en: category[:abr_en], abr_fr: category[:abr_fr], display_en: true, display_fr: true)
      bc.save!
    end
  end

end