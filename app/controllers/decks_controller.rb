# frozen_string_literal: true

# Controller for the Deck resource.
class DecksController < ApplicationController
  include JwtAuthorizationConcern

  def index
    add_total_stat(params)
    base_scope = Deck.where(user_id: @current_user.id)
    params[:filter].delete(:user_id) if params.include?(:filter)
    decks = DeckResource.all(params, base_scope)
    respond_with(decks)
  end

  def show
    deck = DeckResource.find(params)
    respond_with(deck)
  end

  def create
    # TODO(plural): Wrap all of this in a transaction.

    # Use the incoming parameters, but build the actual object against the model directly.

    new_deck = Deck.new
    new_deck.user = current_user
    attributes = params[:data][:attributes]
    card_slots = params[:data][:attributes].delete(:card_slots)
    new_deck.name = attributes[:name]
    new_deck.follows_basic_deckbuilding_rules = attributes[:follows_basic_deckbuilding_rules]
    new_deck.identity_card_id = attributes[:identity_card_id]
    new_deck.side_id = attributes[:side_id]
    new_deck.notes = attributes[:notes]
    new_deck.tags = attributes[:tags]

    # TODO(plural): Flesh out nice error messages.
    raise ApplicationController::BadDeckError, 'There was an error creating your deck.' unless new_deck.save

    new_deck.deck_cards.create(card_id: new_deck.identity_card_id, quantity: 1)
    card_slots.each do |card_id, quantity|
      new_deck.deck_cards.create(card_id:, quantity:)
    end

    simplified_params = { data: { id: new_deck.id, type: 'decks' } }
    deck = DeckResource.find(simplified_params)
    render jsonapi: deck, status: :created
  end

  def update
    attributes = params[:data][:attributes]
    attributes.delete(:faction_id)
    card_slots = attributes.delete(:card_slots)
    deck_resource = DeckResource.find(params)

    ActiveRecord::Base.transaction do
      deck = Deck.find(deck_resource.data.id)

      deck.identity_card_id = attributes.key?(:identity_card_id) ? attributes[:identity_card_id] : deck.identity_card_id
      deck.side_id = attributes.key?(:side_id) ? attributes[:side_id] : deck.side_id
      deck.follows_basic_deckbuilding_rules = if attributes.key?(:follows_basic_deckbuilding_rules)
                                                attributes[:follows_basic_deckbuilding_rules]
                                              else
                                                deck.follows_basic_deckbuilding_rules
                                              end
      deck.name = attributes.key?(:name) ? attributes[:name] : deck.name
      deck.notes = attributes.key?(:notes) ? attributes[:notes] : deck.notes
      deck.tags = attributes.key?(:tags) ? attributes[:tags] : deck.tags
      deck.updated_at = Time.now.utc.to_fs(:iso8601)

      unless card_slots.nil?
        DeckCard.where(deck_id: deck.id).delete_all
        card_slots.each do |card_id, quantity|
          deck.deck_cards.create!(card_id:, quantity:)
        end
      end

      deck.save!
    rescue ActiveRecord::RecordInvalid => e
      raise ApplicationController::BadDeckError, "There was an error updating your deck: #{e.message}"
    end

    deck_resource = DeckResource.find(params)

    render jsonapi: deck_resource
  end

  def destroy
    deck = DeckResource.find(params)

    if deck.destroy
      render jsonapi: { meta: {} }, status: :ok
    else
      render jsonapi_errors: deck
    end
  end
end
