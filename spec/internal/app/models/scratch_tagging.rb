class ScratchTagging < ActiveRecord::Base
  belongs_to :scratch_tag, counter_cache: true
  belongs_to :user
end
