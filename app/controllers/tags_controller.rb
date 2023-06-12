class TagsController < ApplicationController
  before_action :find_resource, only:      %i[show edit update destroy]
  before_action :create_resource, only:    %i[create new]
  before_action :authorize_resource, only: %i[create new show edit destroy update]
  after_action :verify_authorized, except: %i[index all_tags destroy_orphean_tags tag_cloud]

  def index
    # Tags are actually "no-lang"
    # users.taggeds with(tag.name) will return both languages
    # todo: implement language distinction in tags
    @tags = Tag.all.order("#{sort_column} #{sort_direction}")
  end

  # À revisier ... ne correspond pas vraiment au show
  def show
    @tag = Tag.find(params[:id])
    @users_tagged = User.tagged_with(@tag.name)
    @missions_tagged = Mission.tagged_with(@tag.name)
  end

  def merge
    initial_tag_name = params[:current_tag_name]
    target_tag_name = params[:tag_name]
    @tag = Tag.find_by_name(initial_tag_name)
    authorize @tag

    if target_tag_name == ''

      redirect_to :back
    else
      User.tagged_with(initial_tag_name, on: :interests, any: false).each do |user|
        user._list.add(target_tag_name)
        user.interest_list.remove(initial_tag_name)
        user.save
      end

      User.tagged_with(initial_tag_name, on: :skills, any: false).each do |user|
        user.skill_list.add(target_tag_name)
        user.skill_list.remove(initial_tag_name)
        user.save
      end

      User.tagged_with(initial_tag_name, on: :admin_tags, any: false).each do |user|
        user.admin_tag_list.add(target_tag_name)
        user.admin_tag_list.remove(initial_tag_name)
        user.save
      end

      Mission.tagged_with(initial_tag_name, on: :tags, any: false).each do |mission|
        mission.tag_list.add(target_tag_name)
        mission.tag_list.remove(initial_tag_name)
        mission.save
      end

      Speciality.tagged_with(initial_tag_name, on: :sectors, any: false).each do |speciality|
        speciality.sector_list.add(target_tag_name)
        speciality.sector_list.remove(initial_tag_name)
        speciality.save
      end
      Speciality.tagged_with(initial_tag_name, on: :softwares, any: false).each do |speciality|
        speciality.software_list.add(target_tag_name)
        speciality.software_list.remove(initial_tag_name)
        speciality.save
      end

      @tag.destroy
      @tag = Tag.find_by_name(target_tag_name)

      redirect_to tag_path(@tag)
    end
  end

  def all_tags
    expires_in 3.minutes, public: false
    respond_to do |format|
      format.json { render json: Tag.pluck(:name), status: :ok }
    end
  end

  def create
    @tag = Tag.find_by(language: params[:tag][:language], name: params[:tag][:name])
    @tag = Tag.new(tag_params) if @tag.nil?
    @tag.save
    respond_with @tag
  end

  def edit; end

  def update
    @tag.update(tag_params)
    respond_with @tag
  end

  def destroy
    @tag.destroy
    respond_with @tag, location: tags_path
  end

  def destroy_orphean_tags
    TagsCleaner.clean
    redirect_to tags_path
  end

  def tag_cloud
    authorize Tag

    @tags = policy_scope(Tag).order(name: :asc)
  end

  private

  def default_sort_column
    'name'
  end

  def default_sort_order
    'asc'
  end

  def find_resource
    @tag = Tag.find(params[:id])
  end

  def create_resource
    @tag = Tag.new
  end

  def authorize_resource
    authorize @tag
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(
      :name,
      :taggings_count,
      :language,
      :position,
      :role
    )
  end
end
