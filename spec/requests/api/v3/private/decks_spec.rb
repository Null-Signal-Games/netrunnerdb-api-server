# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private API Decks' do
  let(:identity_card_id) { 'asa_group_security_through_vigilance' }
  let(:owner) { User.find_or_create_by!(id: 'plural') }

  let!(:deck) do
    deck = Deck.create!(user: owner, name: 'Deck', side_id: 'corp', identity_card_id:)
    deck.deck_cards.create!(card_id: identity_card_id, quantity: 1)
    deck.deck_cards.create!(card_id: 'adonis_campaign', quantity: 3)
    deck.deck_cards.create!(card_id: 'afshar', quantity: 2)
    deck
  end

  # JwtAuthorizationConcern does not verify the signature, so any key works.
  def patch_deck(attributes)
    token = JWT.encode({ preferred_username: owner.id }, 'test-key', 'HS256')
    patch "/api/v3/private/decks/#{deck.id}",
          params: { data: { id: deck.id, type: 'decks', attributes: } }.to_json,
          headers: { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/vnd.api+json' }
  end

  describe 'PATCH /api/v3/private/decks/:id' do
    it 'updates attributes without touching cards when card_slots is not sent' do
      original_slots = deck.card_slots

      patch_deck({ notes: 'New notes' })

      expect(response).to have_http_status(:ok)
      deck.reload
      expect(deck.notes).to eq('New notes')
      expect(deck.card_slots).to eq(original_slots)
    end

    it 'replaces cards to match card_slots exactly when it is sent' do
      new_slots = { identity_card_id => 1, 'afshar' => 1, 'aiki' => 3 }

      patch_deck({ card_slots: new_slots })

      expect(response).to have_http_status(:ok)
      expect(deck.reload.card_slots).to eq(new_slots)
    end
  end
end
