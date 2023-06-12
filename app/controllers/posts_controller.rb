class PostsController < ApplicationController
  before_action :find_post, only: %i[show edit update destroy]

  def index
    @posts = Post.all
  end

  def show
    @body_classes = 'post'
    image = @post.image.attached? ? url_for(@post.image) : nil
  end

  def show_category
    # skip_authorization

    @posts = Post.tagged_with(params[:slug])
    @body_classes = params[:slug]

    categories = [
      { slug: 'culture', title: 'Culture' },
      { slug: 'entertainment', title: 'Entertainment' },
      { slug: 'style', title: 'Style' },
      { slug: 'news', title: 'News & Views' },
    ]
    array_item = categories.find { |item| item[:slug] == params[:slug] }
    @category = array_item
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    if @post.save
      redirect_to @post, success: 'Post is successfully created'
    else
      rednder :new, error: "Error while creating new post"
    end
  end

  def update
    if @post.update(post_params)
      redirect_to post_path, success: 'Post is successfully updated'
    else
      render :edit, error: "Error while creating new post"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if @post.destroy
      redirect_to posts_path, success: 'Post is successfully deleted'
    else
      render :show, error: 'Error while deleting one post'
    end
  end

  private

  def find_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.fetch(:post, {}).permit(
      :title,
      :author,
      :video_url,
      :published_at,
      :body,
      :image,
      :image_description,
      tag_list: []
    )
  end
end
