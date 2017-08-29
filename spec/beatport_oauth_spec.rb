require "spec_helper"

describe BeatportOauth do
  use_vcr_cassette

  describe 'key, secret, username, password not set' do
    it 'raises an error' do
      expect {
        BeatportOauth.get('/catalog/3/tracks?sortBy=releaseDate+ASC')
      }.to raise_error(StandardError)
    end
  end

  describe 'AccessToken not set' do
    before do
      BeatportOauth.key = "fake"
      BeatportOauth.secret = "fake"
      BeatportOauth.username = "fake"
      BeatportOauth.password = "fake"
    end

    it 'raises an error' do
      expect {
        BeatportOauth.get('/catalog/3/tracks?sortBy=releaseDate+ASC')
      }.to raise_error(StandardError)
    end
  end

  describe 'vars setup correctly' do
    before do
      BeatportOauth.key = "fake"
      BeatportOauth.secret = "fake"
      BeatportOauth.username = "fake"
      BeatportOauth.password = "fake"
    end

    it "has a version number" do
      expect(BeatportOauth::VERSION).to eq '0.1.0'
    end

    it 'gets an access token' do
      expect(BeatportOauth.get_access_token).to eq({
        "oauth_token"        => "fake",
        "oauth_token_secret" => "fake123"
      })
    end

    describe 'Access token has been set' do
      before { BeatportOauth.access_token = BeatportOauth.get_access_token }

      it "can get a catalog page" do
        expect(BeatportOauth.get('/catalog/3/tracks?sortBy=releaseDate+ASC').keys).to eq(["metadata", "results"])
      end
    end
  end
end
