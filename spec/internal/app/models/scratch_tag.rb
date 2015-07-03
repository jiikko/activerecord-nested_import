class ScratchTag < ActiveRecord::Base
  has_many :scratch_taggings, dependent: :destroy
end
