# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private API Decks' do
  let(:identity_card_id) { 'asa_group_security_through_vigilance' }
  let(:owner) { User.find_or_create_by!(id: 'plural') }
  let(:other_user) { User.find_or_create_by!(id: 'ams') }

  let!(:deck) do
    deck = Deck.create!(user: owner, name: 'Deck', side_id: 'corp', identity_card_id:)
    deck.deck_cards.create!(card_id: identity_card_id, quantity: 1)
    deck.deck_cards.create!(card_id: 'adonis_campaign', quantity: 3)
    deck.deck_cards.create!(card_id: 'afshar', quantity: 2)
    deck
  end

  # JwtAuthorizationConcern does not verify the signature, so any key works.
  def auth_headers(user = owner)
    token = JWT.encode({ preferred_username: user.id }, 'test-key', 'HS256')
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/vnd.api+json' }
  end

  def patch_deck(attributes, user: owner)
    patch "/api/v3/private/decks/#{deck.id}",
          params: { data: { id: deck.id, type: 'decks', attributes: } }.to_json,
          headers: auth_headers(user)
  end

  describe 'access to another user\'s deck' do
    it 'returns 404 for GET' do
      get "/api/v3/private/decks/#{deck.id}", headers: auth_headers(other_user)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for PATCH and leaves the deck unchanged' do
      original_slots = deck.card_slots

      patch_deck({ name: 'Stolen', card_slots: { 'aiki' => 3 } }, user: other_user)

      expect(response).to have_http_status(:not_found)
      deck.reload
      expect(deck.name).to eq('Deck')
      expect(deck.card_slots).to eq(original_slots)
    end

    it 'returns 404 for DELETE and leaves the deck in place' do
      delete "/api/v3/private/decks/#{deck.id}", headers: auth_headers(other_user)

      expect(response).to have_http_status(:not_found)
      expect(Deck.exists?(deck.id)).to be(true)
    end
  end

  describe 'access to your own deck' do
    it 'deletes the deck for DELETE' do
      delete "/api/v3/private/decks/#{deck.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(Deck.exists?(deck.id)).to be(false)
    end
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
