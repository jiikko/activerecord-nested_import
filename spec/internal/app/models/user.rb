class User < ActiveRecord::Base
  acts_as_taggable_on :tags

  has_many :scratch_taggings
  has_many :scratch_tags, through: :scratch_taggings
end
