require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do
    let(:movie_data) {
      {
        "title": "Jack the Movie",
        "overview": "A cool movie",
        "release_date": "Oct 23 2018",
        "external_id": 10,
        "image_url": "image",
      }
    }

    it "creates a new movie given valid data" do

      expect {
        post movies_path, params: movie_data
      }.must_change "Movie.count", 1

      body = JSON.parse(response.body)

      expect(body).must_be_kind_of Hash
      expect(body).must_include "id"

      movie = Movie.find(body["id"].to_i)
      expect(movie.title).must_equal movie_data[:title]
      must_respond_with :success

    end


    it "returns an error for invalid movie data" do
      # arrange
      movie_data["title"] = nil

      expect {
        post movies_path, params: { movie: movie_data }
      }.wont_change "Movie.count"

      body = JSON.parse(response.body)

      expect(body).must_be_kind_of Hash
      expect(body).must_include "message"
      expect(body["message"]).must_include "title"
      must_respond_with :bad_request
    end

    it "returns an error for invalid movie data" do
      # arrange
      movie_data["overview"] = nil

      expect {
        post movies_path, params: { movie: movie_data }
      }.wont_change "Movie.count"

      body = JSON.parse(response.body)

      expect(body).must_be_kind_of Hash
      expect(body).must_include "message"
      expect(body["message"]).must_include "overview"
      must_respond_with :bad_request
    end

    it "returns an error for invalid movie data" do
      # arrange
      movie_data["release_date"] = nil

      expect {
        post movies_path, params: { movie: movie_data }
      }.wont_change "Movie.count"

      body = JSON.parse(response.body)

      expect(body).must_be_kind_of Hash
      expect(body).must_include "message"
      expect(body["message"]).must_include "release_date"
      must_respond_with :bad_request
    end

    it "returns an error for invalid movie data" do
      # arrange
      movie_data["external_id"] = nil

      expect {
        post movies_path, params: { movie: movie_data }
      }.wont_change "Movie.count"

      body = JSON.parse(response.body)

      expect(body).must_be_kind_of Hash
      expect(body).must_include "message"
      expect(body["message"]).must_include "external_id"
      must_respond_with :bad_request
    end




  end
end
