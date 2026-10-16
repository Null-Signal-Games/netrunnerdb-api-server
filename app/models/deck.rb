# frozen_string_literal: true

# Model for Deck objects.
#
# Decks are private, unpublished decklists that belong to a user.
class Deck < ApplicationRecord
  belongs_to :user
  belongs_to :side

  has_one :identity_card, # rubocop:disable Rails/InverseOf
          class_name: 'Card',
          foreign_key: 'id',
          primary_key: 'identity_card_id'

  delegate :faction_id, to: :identity_card
  scope :by_faction, lambda { |faction_id|
    # unified_cards is the table name, not the model name here in the where clause
    joins(:identity_card).where(unified_cards: { faction_id: })
  }
  has_one :faction, through: :identity_card

  has_many :deck_cards, dependent: :delete_all
  has_many :cards, through: :deck_cards

  def card_slots
    deck_cards.order(:card_id).to_h { |c| [c.card_id, c.quantity] }
  end

  def num_cards
    deck_cards
      # Exclude identity
      .reject { |c| c.card_id == identity_card_id }
      .map(&:quantity).sum
  end
end
