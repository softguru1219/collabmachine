require 'net/http'
require 'net/https'

class HelloController < ApplicationController
  skip_before_action :authenticate_user!

  include SpecialtiesHelper

  def index
    render layout: 'front'
  end

  def wiphomepage
    @specialties = Specialty.where.not(title: nil).order(:title)
    
    @marketing_categories = BusinessSubDomain.where('name @> ?', {en: "Marketing"}.to_json).first.business_categories
    @marketing_categories = alphabetic_sort(@marketing_categories).map { |businessCategory| businessCategory if businessCategory.specialties.present? }.compact
    @marketing_categories = @marketing_categories.take(9)
    @marketing_specialties = Specialty.where(business_sub_domain_id: BusinessSubDomain.where('name @> ?', {en: "Marketing"}.to_json).first.id)
    
    @information_categories = BusinessSubDomain.where('name @> ?', {fr: "Informatique"}.to_json).first.business_categories
    @information_categories = alphabetic_sort(@information_categories).map { |businessCategory| businessCategory if businessCategory.specialties.present? }.compact
    @information_categories = @information_categories.take(9)
    @information_specialties = Specialty.where(business_sub_domain_id: BusinessSubDomain.where('name @> ?', {fr: "Informatique"}.to_json).first.id)

    @missions = Mission.order(:title).limit(12)
    @specialists = Specialist.joins(:user).order(:first_name).limit(12)
    @sectors = alphabetic_sort(Sector.all)
    @sector_specialties_count = SpecialtyLine.where.not(sector_id: nil).pluck(:specialty_id).uniq.length
    @projects = Project.order(:title).limit(12)

    @skill_users = User.active.includes(:skills).where.not(skills: { id: nil })
    @technologies = (@skill_users.map{|t| t.skill_list}).flatten.uniq.sort_by(&:downcase)
    @technologies_specialties_count = @skill_users.map{|t| t.specialties}.flatten.compact.uniq.length
    @python_count = @skill_users.map{|t| t if t.skill_list.include?("python")}.flatten.compact.length

    render layout: 'front'
  end

  # the old homepage (v1)
  def index_first
    @body_classes = 'homepage'
    render layout: 'front'
  end

  def hire
    render layout: 'front'
  end

  def work
    render layout: 'front'
  end

  def team
    render layout: 'front'
  end

  def partners
    render layout: 'front'
  end

  def results
    @title = ""

    @body_classes = 'bg-light'

    if params[:section].present?
      case params[:section]
      when 'categories'
        @businessCategory = BusinessCategory.where(id: params[:id])
        @results = @businessCategory.present? ? @businessCategory.first.specialties : []
      when "specialties"
        @results = Specialty.where(id: params[:id])
      when "sectors"
        @specialtyLines = SpecialtyLine.where(sector_id: params[:id])
        @results = []
        @specialtyLines.each do |specialtyLine|
          @results << specialtyLine.specialty
        end
      end
    else
      @results = Specialty.where.not(title: nil).order(:title)
    end
    
    if @results.present?
      if @results.first.business_sub_domain.present?
        @title += @results.first.business_sub_domain.name
      end
      if @results.first.business_category.present?
        @title += " #{@results.first.business_category.name}"
      end
    end
  end

  def show_results
    @body_classes = 'bg-light'
    @specialty = Specialty.find(params[:id])
  end

  def send_results
    wip_params = params[:wip_result]

    wipResult = WipResult.new
    wipResult.specialty_id = wip_params[:specialty_id]
    wipResult.work_type = wip_params[:work_type]
    wipResult.start_date = wip_params[:start_date]
    wipResult.end_date = wip_params[:end_date]
    wipResult.classification = wip_params[:classification]
    wipResult.save
    
    # begin
    #   status = Timeout::timeout(5) {
    #     MessageMailer.send_wip_results(wip_params[:specialty_id])
    #   }
    # rescue Exception => ex
    #   puts("error: #{ex.to_s}")
    # end

    redirect_to final_results_path(wipResult.id, wip_params[:specialty_id])
  end

  def final_results
    @body_classes = 'bg-light'
    @wip_id = params[:wip_id]
    @specialty = params[:specialty_id]
  end

  def results_email
    @specialty = Specialty.first
  end

  def randomly
    @skip_footer = true
    render layout: 'front'
  end

  def styledeck
    render layout: 'front'
  end

  def payment
    @skip_footer = true
    render layout: 'front'
  end

  def payment_gateway
    @skip_footer = true
    render layout: 'front'
  end

  def avantages_membre
    prepare_meta_tags(
      title: "12 avantages à être membre du réseau CollabMachine [FAQ]",
      description: "Découvrez les avantages à être membre du réseau CollabMachine. Vous n’avez qu’à inscrire un spécialiste en informatique, en e-commerce ou en marketing digital.",
      keywords: %w[Collab\ Machine RH ressources\ humaines spécialistes personnel\ temporaire placement\ de\ personnel informatique e-commerce marketing\ digital webmarketing réseau\ CollabMachine]
    )
    @skip_footer = true
    @body_classes = 'bg-light'
    render layout: 'front'
  end

  def get_specialist
    prepare_meta_tags(
      title: "Comment obtenir un spécialiste grâce à CollabMachine",
      description: "Découvrez comment obtenir un spécialiste en informatique, en e-commerce ou en marketing digital. Des centaines de spécialités offertes. Personnel temporaire.",
      keywords: %w[Collab\ Machine RH ressources\ humaines spécialistes personnel\ temporaire placement\ de\ personnel informatique e-commerce marketing\ digital webmarketing]
    )

    @skip_footer = true
    @body_classes = 'specialties bg-light'
    render layout: 'front'
  end

  def get_contracts
    @skip_footer = true
    @body_classes = 'specialties bg-light'
    render layout: 'front'
  end

  def propose_project
    prepare_meta_tags(
      title: "Un projet informatique, e-commerce ou marketing à réaliser ?",
      description: "Nous avons des centaines de spécialistes pour réaliser vos projets informatiques, e-commerce ou marketing. Demandez une soumission.",
      keywords: %w[Collab\ Machine projet\ informatique projet\ e-commerce projet\ en\ marketing\ digital spécialistes]
    )
    @skip_footer = true
    @body_classes = 'specialties bg-light'
    render layout: 'front'
  end

  def mastermind_pointdebascule
    prepare_meta_tags(
      title: "Mastermind - Point de Bascule©",
      description: "C'est un groupe de propulsion mutuelle pour participants sélectionnés. Chaque membre est propulsé vers l'atteinte de son objectif d'importance et participe à l’atteinte du Point de Bascule des autres membres de son groupe.",
      image: ActionController::Base.helpers.asset_path('dashboard/MMPB-terre-saturne.png').to_s
    )

    @skip_footer = true
    render layout: 'front'
  end

  def your_serviceplace
    @skip_footer = true
    render layout: 'front'
  end

  def terms_conditions
    render layout: 'front'
  end

  def event20220505
    @skip_footer = true
    render layout: 'front'
  end

  def sandbox_program
    @skip_footer = true
    render layout: 'front'
  end

  def sandbox
    @body_classes = 'sandbox'
  end

  def ten_slides
    render layout: 'fullpagejs'
  end

  def digital_entrepreneurs
    @title = "Collab Machine"
    render layout: 'fullpagejs'
  end

  def contact
    @body_classes = 'bg-light'
    render layout: 'front'
  end

  def sitemap
    url = "#{request.base_url}/sitemap.xml"
    resp = Nokogiri::XML(open(url))
    @urls = resp.css('urlset > url')
    @locale = params[:locale] || "fr"
    @locale = "/#{@locale}/"

    @dict = {}
    @urls.each_with_index do |url_element, _idx|
      url_element.children.each do |child_element|
        next unless child_element.namespace.prefix == 'news'

        if child_element.children.length == 2
          child_element.children.each do |grand_child_element|
            next unless grand_child_element.name == 'title'

            title = grand_child_element.content
            if title.present?
              if @dict.key?(title.to_sym)
                @dict[title.to_sym][:urls].push(url_element.css('loc').first.content)
              else
                @dict[title.to_sym] = { urls: [url_element.css('loc').first.content], values: [] }
              end
            end
          end
        end
        next unless child_element.children.length == 3

        @title = nil
        child_element.children.each do |grand_child_element|
          @title = grand_child_element.content if grand_child_element.name == 'title'
          next unless grand_child_element.name == 'keywords'

          keywords = grand_child_element.content
          next unless @title.present? && @dict.key?(keywords.to_sym)
          url = url_element.css('loc').first.content
          @dict[keywords.to_sym][:values].push(
            { title: @title, url: url_element.css('loc').first.content }
          )
        end
      end
    end
    @dict
    render layout: "front"
  end
end