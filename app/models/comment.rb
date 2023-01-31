class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :body, presence: true, allow_blank: false
  validates :commenter, presence: true, allow_blank: false

  def archived?
    status == 'archived'
  end
end
