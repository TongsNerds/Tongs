class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :posts, dependent: :destroy  
  has_many :responses, dependent: :destroy
  has_many :likes
  has_many :liked_posts, through: :likes, source: :likeable, source_type: "Post"
  has_many :liked_responses, through: :likes, source: :likeable, source_type: "Response"

  validates :username, uniqueness: { case_sensitive: false }, presence: true
  
  validate :avatar_image_size

  include UserFollowing
  include TagFollowing
  mount_uploader :avatar, AvatarUploader

  def add_like_to(likeable_obj)
    likes.where(likeable: likeable_obj).first_or_create
  end

  def remove_like_from(likeable_obj)
    likes.where(likeable: likeable_obj).destroy_all
  end

  def liked?(likeable_obj)
    send("liked_#{downcased_class_name(likeable_obj)}_ids").include?(likeable_obj.id)
  end

  private

    def avatar_image_size
      if avatar.size > 5.megabytes
      	errors.add(:avatar, "should be less than 5MB")
      end
    end

    #returns a string of the objects class name downcased
    def downcased_class_name(obj)
      obj.class.to_s.downcase
    end
end
