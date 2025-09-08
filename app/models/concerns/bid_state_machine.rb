module BidStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM
    aasm column: 'status', enum: true do
      state :active, initial: true
      state :outdated # a state to indicate this bid is former bid for a user
      state :winning

      event :outdate do
        transitions from: :active, to: :outdated
      end
      event :win do
        transitions from: :active, to: :winning
      end
    end
  end
end
