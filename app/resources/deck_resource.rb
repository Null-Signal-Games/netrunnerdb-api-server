# frozen_string_literal: true

# Private resource for Deck objects.
class DeckResource < PrivateApplicationResource
  primary_endpoint '/decks', %i[index show create update destroy]

  attribute :id, :uuid
  attribute :user_id, :string
  attribute :follows_basic_deckbuilding_rules, :boolean
  attribute :identity_card_id, :string
  attribute :name, :string
  attribute :notes, :string
  attribute :tags, :array_of_strings
  attribute :side_id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  attribute :faction_id, :string, writable: false, filterable: true do
    id = Card.find(@object.identity_card_id)
    id&.faction_id
  end

  filter :faction_id, :string do
    eq do |scope, value|
      scope.by_faction(value)
    end
  end

  attribute :card_slots, :hash
  attribute :num_cards, :integer

  # This is the basic definition, but does not take restriction modifications
  # into account. Leaving this here as an example for now, but it will need to
  # be removed in favor of snapshot-specific calculations.
  attribute :influence_spent, :integer do
    qty = {}
    @object.deck_cards.each do |c|
      qty[c.card_id] = c.quantity
    end
    Rails.logger.info format('qty is %s', qty.inspect)
    id = Card.find(@object.identity_card_id)
    @object.cards
           .filter { |c| c.faction_id != id.faction_id }
           .map { |c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id]) }
           .sum
  end

  # TODO(plural): Fix user relationship.
  # belongs_to :user

  belongs_to :side
  # The rubocop warning is disabled because this relationship won't work without the foreign_key
  # explicitly set, presumably because this is a delegated field on the model.
  belongs_to :faction, foreign_key: :faction_id do # rubocop:disable Rails/RedundantForeignKey
    link do |decklist|
      format('%<url>s/%<id>s', url: Rails.application.routes.url_helpers.factions_url, id: decklist.faction_id)
    end
  end

  many_to_many :cards

  def base_scope
    Deck.where(user_id: context.current_user.id)
  end
end
