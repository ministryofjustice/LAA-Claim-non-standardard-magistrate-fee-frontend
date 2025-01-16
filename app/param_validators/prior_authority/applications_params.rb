module PriorAuthority
  class ApplicationsParams < BaseParamValidator
    attribute :id, :string
    attribute :application_id, :string

    validates :application_id, presence: true
  end
end
